import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/debounce.dart';
import 'package:trackyourflights/presentation/nonce.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/repositories.dart';

class Either<T, TError> {
  const Either.value(this.value) : error = null;
  const Either.error(this.error) : value = null;
  const Either.empty()
      : error = null,
        value = null;

  final T? value;
  final TError? error;
}

class SearchError {
  const SearchError(this.text, {this.showSearchRangeSuggestion = false});

  final bool showSearchRangeSuggestion;
  final String text;
}

class FlightPresenter extends CompletePresenterStandalone {
  final GlobalKey<FormState> formKey = GlobalKey();

  final TextEditingController flightAwareLinkController =
      TextEditingController();
  final FocusNode flightAwareLinkFocusNode = FocusNode();
  String _lastFlightAwareLink = '';

  final TextEditingController flightNumberController = TextEditingController();
  final FocusNode flightNumberFocusNode = FocusNode();

  DateTime? flightDate;

  final TextEditingController personsController = TextEditingController();

  final TextEditingController departureTimeController = TextEditingController();
  final FocusNode departureTimeFocusNode = FocusNode();

  final TextEditingController departureAirportController =
      TextEditingController();
  final FocusNode departureAirportFocusNode = FocusNode();

  String _lastDepartureAirport = '';

  bool departureTimeSet = false;
  int departureHours = 0;
  int departureMinutes = 0;

  final TextEditingController arrivalAirportController =
      TextEditingController();
  final FocusNode arrivalAirportFocusNode = FocusNode();
  String _lastArrivalAirport = '';

  Either<FlightPresearchResult, dynamic> flightPresearch = const Either.empty();
  Either<List<Flight>, SearchError> foundFlights = const Either.empty();

  final Debounce _presearchDebounce = Debounce();
  final Nonce _foundFlightsNonce = Nonce();

  Flight? get selectedFlight => foundFlights.value?.firstOrNull;

  bool flightLoading = false;

  bool _findByFlightAwareLink = false;

  bool get findByFlightAwareLink => _findByFlightAwareLink;
  set findByFlightAwareLink(val) {
    _findByFlightAwareLink = val;
    foundFlights = const Either.empty();
    if (_findByFlightAwareLink) {
      _maybeSearchByFlightawareLink();
    } else {
      _onSearchParametersChanged();
    }
    notify();
  }

  @override
  void initState() {
    super.initState();
    flightNumberController.addListener(_onFlightNumberChanged);
    flightNumberFocusNode.addListener(_onSearchParametersChanged);
    departureTimeFocusNode.addListener(_onDepartureTimeChanged);
    departureAirportFocusNode.addListener(() {
      if (!departureAirportFocusNode.hasFocus &&
          _lastDepartureAirport != departureAirportController.text.trim()) {
        _lastDepartureAirport = departureAirportController.text.trim();
        _onSearchParametersChanged();
      }
    });
    arrivalAirportFocusNode.addListener(() {
      if (!arrivalAirportFocusNode.hasFocus &&
          _lastArrivalAirport != arrivalAirportController.text.trim()) {
        _lastArrivalAirport = arrivalAirportController.text.trim();
        _onSearchParametersChanged();
      }
    });
    flightAwareLinkFocusNode.addListener(() {
      if (!flightAwareLinkFocusNode.hasFocus &&
          _lastFlightAwareLink != flightAwareLinkController.text.trim()) {
        _lastFlightAwareLink = flightAwareLinkController.text.trim();
        _maybeSearchByFlightawareLink();
      }
    });
  }

  void _onFlightNumberChanged() {
    _presearchDebounce.exec((nonce) async {
      final newFlightNumber = flightNumberController.text.trim();
      flightPresearch = const Either.empty();
      if (newFlightNumber.isEmpty) {
        return;
      }
      final value = await flightSearchRepository.presearch(newFlightNumber);
      if (!_presearchDebounce.shouldApplyValue(nonce)) {
        return;
      }
      flightPresearch = Either.value(value);
      notify();

      _onSearchParametersChanged();
    });
  }

  Future<void> selectFlightDate() async {
    final date = await showDatePicker(
      context: context!,
      initialDate: flightDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.input,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;
    flightDate = DateTime.utc(date.year, date.month, date.day);
    notify();

    _onSearchParametersChanged();
  }

  void _onDepartureTimeChanged() {
    if (departureTimeFocusNode.hasFocus) {
      return;
    }
    final oldDepartureHours = departureHours;
    final oldDepartureMinutes = departureMinutes;
    final oldDepartureTimeSet = departureTimeSet;
    if (departureTimeController.text.trim().isEmpty) {
      departureHours = 0;
      departureMinutes = 0;
      departureTimeSet = false;
    } else {
      final time = DateTimeParser.time(context!, departureTimeController.text);
      if (time == null) {
        return;
      }
      departureHours = time.hour;
      departureMinutes = time.minute;
      departureTimeSet = true;
    }

    if (oldDepartureTimeSet != departureTimeSet ||
        oldDepartureMinutes != departureMinutes ||
        oldDepartureHours != departureHours) {
      _onSearchParametersChanged();
    }
  }

  void _onSearchParametersChanged() {
    if (flightNumberFocusNode.hasFocus) {
      return;
    }
    if (flightPresearch.value == null) {
      return;
    }
    if (flightDate == null) {
      return;
    }
    if (!_findByFlightAwareLink) {
      searchFlights();
    }
  }

  void _maybeSearchByFlightawareLink() {
    if (!_findByFlightAwareLink ||
        flightAwareLinkController.text.trim().isEmpty) {
      return;
    }
    searchFlights(
      searchByFlightawareLink: true,
    );
  }

  Future<void> searchFlights({
    searchByFlightawareLink = false,
  }) async {
    flightLoading = true;
    foundFlights = const Either.empty();
    notify();

    final nonce = _foundFlightsNonce.increase();

    try {
      final List<Flight> flights;
      if (searchByFlightawareLink) {
        flights = await flightSearchRepository
            .findByFlightaware(flightAwareLinkController.text.trim());
      } else {
        flights = await flightSearchRepository.find(
          flightPresearch.value!.ident,
          flightDate!.add(
            Duration(
              hours: departureHours,
              minutes: departureMinutes,
            ),
          ),
          checkTime: departureTimeSet,
          destItea: arrivalAirportController.text.trim().isEmpty
              ? null
              : arrivalAirportController.text.trim(),
          originItea: departureAirportController.text.trim().isEmpty
              ? null
              : arrivalAirportController.text.trim(),
        );
      }

      if (!_foundFlightsNonce.shouldApplyValue(nonce)) {
        return;
      }

      if (flights.isNotEmpty) {
        foundFlights = Either.value(flights);
      } else {
        foundFlights = const Either.error(
          SearchError(
            'Flight not found :(',
            showSearchRangeSuggestion: true,
          ),
        );
      }
    } catch (e) {
      if (!_foundFlightsNonce.shouldApplyValue(nonce)) {
        return;
      }

      foundFlights =
          const Either.error(SearchError('Oh no, I faced some problems'));
    } finally {
      if (_foundFlightsNonce.shouldApplyValue(nonce)) {
        flightLoading = false;
        notify();
      }
    }
  }

  String? validate() {
    if (flightLoading) {
      return 'Wait a moment, we are searching';
    }
    if (!formKey.currentState!.validate()) {
      return 'Oops. Issues found, please fix them';
    }
    if (foundFlights.error != null) {
      return 'There\'s an error in flight search';
    }
    if (foundFlights.value?.isEmpty ?? true) {
      return 'Flights not found yet';
    }
    return null;
  }

  OrderFlight get flight => OrderFlight(
        flight: selectedFlight!,
        personsCount: int.parse(personsController.text),
      );

  @override
  void dispose() {
    super.dispose();
    flightAwareLinkController.dispose();
    flightAwareLinkFocusNode.dispose();
    personsController.dispose();
    flightNumberController.dispose();
    flightNumberFocusNode.dispose();
    departureAirportController.dispose();
    departureAirportFocusNode.dispose();
    arrivalAirportController.dispose();
    arrivalAirportFocusNode.dispose();
    departureTimeController.dispose();
    departureTimeFocusNode.dispose();
  }
}
