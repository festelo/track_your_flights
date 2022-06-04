import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/date_formats.dart';
import 'package:trackyourflights/presentation/debounce.dart';
import 'package:trackyourflights/presentation/nonce.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/flight_search_presenter.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:trackyourflights/repositories.dart';

import 'flight_search_by_params_state.dart';

class FlightSearchByParamsPresenter implements FlightSearchPresenter {
  FlightSearchByParamsPresenter(
    this._notify,
    this._contextResolver,
  );

  final FlightSearchByParamsState state = FlightSearchByParamsState();
  final VoidCallback _notify;
  final BuildContext Function() _contextResolver;

  BuildContext get _context => _contextResolver();

  final Debounce _presearchDebounce = Debounce();
  final Nonce _foundFlightsNonce = Nonce();

  String _lastDepartureAirport = '';
  String _lastArrivalAirport = '';

  @override
  String? get preview => state.flightPresearch.value?.description;

  @override
  void initState() {
    state.flightNumberController.addListener(_onFlightNumberChanged);
    state.flightNumberFocusNode.addListener(_onSearchParametersChanged);
    state.departureTimeFocusNode.addListener(_onDepartureTimeChanged);
    state.departureAirportFocusNode.addListener(() {
      if (!state.departureAirportFocusNode.hasFocus &&
          _lastDepartureAirport !=
              state.departureAirportController.text.trim()) {
        _lastDepartureAirport = state.departureAirportController.text.trim();
        _onSearchParametersChanged();
      }
    });
    state.arrivalAirportFocusNode.addListener(() {
      if (!state.arrivalAirportFocusNode.hasFocus &&
          _lastArrivalAirport != state.arrivalAirportController.text.trim()) {
        _lastArrivalAirport = state.arrivalAirportController.text.trim();
        _onSearchParametersChanged();
      }
    });
  }

  void _onFlightNumberChanged() {
    _presearchDebounce.exec((nonce) async {
      final newFlightNumber = state.flightNumberController.text.trim();
      state.flightPresearch = const Either.empty();
      if (newFlightNumber.isEmpty) {
        return;
      }
      final value = await flightSearchRepository.presearch(newFlightNumber);
      if (!_presearchDebounce.shouldApplyValue(nonce)) {
        return;
      }
      state.flightPresearch = Either.value(value);
      _notify();

      _onSearchParametersChanged();
    });
  }

  Future<void> selectFlightDate() async {
    final date = await showDatePicker(
      context: _context,
      initialDate: state.flightDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.input,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;
    state.flightDate = DateTime.utc(date.year, date.month, date.day);
    _notify();

    _onSearchParametersChanged();
  }

  void _onDepartureTimeChanged() {
    if (state.departureTimeFocusNode.hasFocus) {
      return;
    }
    final oldDepartureHours = state.departureHours;
    final oldDepartureMinutes = state.departureMinutes;
    final oldDepartureTimeSet = state.departureTimeSet;
    if (state.departureTimeController.text.trim().isEmpty) {
      state.departureHours = 0;
      state.departureMinutes = 0;
      state.departureTimeSet = false;
    } else {
      final time =
          DateTimeParser.time(_context, state.departureTimeController.text);
      if (time == null) {
        return;
      }
      state.departureHours = time.hour;
      state.departureMinutes = time.minute;
      state.departureTimeSet = true;
    }

    if (oldDepartureTimeSet != state.departureTimeSet ||
        oldDepartureMinutes != state.departureMinutes ||
        oldDepartureHours != state.departureHours) {
      _onSearchParametersChanged();
    }
  }

  void _onSearchParametersChanged() {
    if (state.flightNumberFocusNode.hasFocus) {
      return;
    }
    if (state.flightPresearch.value == null) {
      return;
    }
    if (state.flightDate == null) {
      return;
    }
    _searchFlights();
  }

  Future<void> _searchFlights() async {
    state.flightLoading = true;
    state.foundFlights = const Either.empty();
    _notify();

    final nonce = _foundFlightsNonce.increase();

    try {
      final List<Flight> flights;
      flights = await flightSearchRepository.find(
        state.flightPresearch.value!.ident,
        state.flightDate!.add(
          Duration(
            hours: state.departureHours,
            minutes: state.departureMinutes,
          ),
        ),
        checkTime: state.departureTimeSet,
        destItea: state.arrivalAirportController.text.trim().isEmpty
            ? null
            : state.arrivalAirportController.text.trim(),
        originItea: state.departureAirportController.text.trim().isEmpty
            ? null
            : state.arrivalAirportController.text.trim(),
      );

      if (!_foundFlightsNonce.shouldApplyValue(nonce)) {
        return;
      }

      if (flights.isNotEmpty) {
        state.foundFlights = Either.value(flights);
      } else {
        state.foundFlights = const Either.error(
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

      state.foundFlights =
          const Either.error(SearchError('Oh no, I faced some problems'));
    } finally {
      if (_foundFlightsNonce.shouldApplyValue(nonce)) {
        state.flightLoading = false;
        _notify();
      }
    }
  }

  @override
  FlightOrSearch flightOrSearch() =>
      FlightOrSearch.flight(state.selectedFlight!);

  @override
  String? validate() {
    if (state.flightLoading) {
      return 'Wait a moment, we are searching';
    }
    if (state.foundFlights.error != null) {
      return 'There\'s an error in flight search';
    }
    if (state.foundFlights.value?.isEmpty ?? true) {
      return 'Flights not found yet';
    }
    return null;
  }

  @override
  void dispose() {
    state.flightNumberController.dispose();
    state.flightNumberFocusNode.dispose();
    state.departureAirportController.dispose();
    state.departureAirportFocusNode.dispose();
    state.arrivalAirportController.dispose();
    state.arrivalAirportFocusNode.dispose();
    state.departureTimeController.dispose();
    state.departureTimeFocusNode.dispose();
  }
}
