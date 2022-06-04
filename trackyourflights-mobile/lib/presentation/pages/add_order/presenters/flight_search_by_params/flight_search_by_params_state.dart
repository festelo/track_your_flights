import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:collection/collection.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';

class FlightSearchByParamsState {
  final TextEditingController departureTimeController = TextEditingController();
  final FocusNode departureTimeFocusNode = FocusNode();

  final TextEditingController departureAirportController =
      TextEditingController();
  final FocusNode departureAirportFocusNode = FocusNode();

  final TextEditingController arrivalAirportController =
      TextEditingController();
  final FocusNode arrivalAirportFocusNode = FocusNode();

  bool departureTimeSet = false;
  int departureHours = 0;
  int departureMinutes = 0;

  final TextEditingController flightNumberController = TextEditingController();
  final FocusNode flightNumberFocusNode = FocusNode();

  DateTime? flightDate;

  Either<FlightPresearchResult, dynamic> flightPresearch = const Either.empty();

  bool flightLoading = false;

  Either<List<Flight>, SearchError> foundFlights = const Either.empty();

  Flight? get selectedFlight => foundFlights.value?.firstOrNull;
}
