import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_query_result.dart';
import 'package:trackyourflights/presentation/debounce.dart';
import 'package:trackyourflights/presentation/nonce.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';
import 'package:trackyourflights/repositories.dart';

class FlightPresenter extends CompletePresenterStandalone {
  final TextEditingController flightNumberController = TextEditingController();
  final FocusNode flightNumberFocusNode = FocusNode();
  final TextEditingController personsController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  String? flightInfo;
  bool flightInfoError = false;
  DateTime? flightDate;

  String? flightFindingError;
  bool flightLoading = false;

  final Debounce _searchDebounce = Debounce();
  final Nonce _foundFlightsNonce = Nonce();

  List<FlightQueryResult> foundFlights = [];
  FlightQueryResult get selectedFlight => foundFlights.first;

  @override
  void initState() {
    super.initState();
    flightNumberController.addListener(
      () => _searchDebounce.exec(
        (i) => _onFlightNumberChanged(i),
      ),
    );
    flightNumberFocusNode.addListener(() {
      if (!flightNumberFocusNode.hasFocus &&
          flightDate != null &&
          !flightInfoError &&
          flightNumberController.text.trim().isNotEmpty) {
        searchFlights();
      }
    });
  }

  void _onFlightNumberChanged(int nonce) async {
    String? flightInfo;
    bool flightInfoError;
    if (flightNumberController.text.trim().isEmpty) {
      flightInfo = null;
      flightInfoError = false;
    } else {
      final value =
          await flightSearchRepository.presearch(flightNumberController.text);
      flightInfo = value;
      flightInfoError = value == null;
    }
    if (_searchDebounce.shouldApplyValue(nonce)) {
      this.flightInfo = flightInfo;
      this.flightInfoError = flightInfoError;
      if (flightInfo != null &&
          !flightNumberFocusNode.hasFocus &&
          flightDate != null) {
        searchFlights();
      }
      notify();
    }
  }

  Future<void> selectFlightDate() async {
    final date = await showDatePicker(
      context: context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null) return;
    flightDate = date;
    notify();

    if (!flightInfoError && flightNumberController.text.trim().isNotEmpty) {
      searchFlights();
    }
  }

  Future<void> searchFlights() async {
    flightFindingError = null;
    foundFlights = [];
    flightLoading = true;
    notify();
    final nonce = _foundFlightsNonce.increase();
    try {
      final flights = await flightSearchRepository.find(
          flightNumberController.text, flightDate!);

      if (_foundFlightsNonce.shouldApplyValue(nonce)) {
        foundFlights = flights;
        if (flights.isEmpty) {
          flightFindingError = 'Flight not found :(';
        } else {
          flightFindingError = null;
        }
        flightLoading = false;
        notify();
      }
    } catch (e) {
      if (_foundFlightsNonce.shouldApplyValue(nonce)) {
        flightFindingError = 'Oh no, I faced some problems';
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
    if (flightFindingError != null || foundFlights.isEmpty) {
      return 'There\'s an error in flight search';
    }
    return null;
  }

  Flight get flight => Flight(
        id: selectedFlight.id,
        from: selectedFlight.from,
        to: selectedFlight.to,
        airplane: selectedFlight.airplane,
        flightAwareLink: selectedFlight.flightAwareLink,
        personsCount: int.parse(personsController.text),
      );

  @override
  void dispose() {
    super.dispose();
    personsController.dispose();
    flightNumberFocusNode.dispose();
  }
}
