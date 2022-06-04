import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';

class FlightSearchByTimeRangeState {
  final TextEditingController aproxTimeController = TextEditingController();

  final TextEditingController departureAirportController =
      TextEditingController();

  final TextEditingController arrivalAirportController =
      TextEditingController();

  final TextEditingController flightNumberController = TextEditingController();

  DateTime? aproxDate;

  Either<FlightPresearchResult, dynamic> flightPresearch = const Either.empty();

  FlightSearch? _flightSearch;

  FlightOrSearch? get flightOrSearch =>
      _flightSearch == null ? null : FlightOrSearch.search(_flightSearch!);
}
