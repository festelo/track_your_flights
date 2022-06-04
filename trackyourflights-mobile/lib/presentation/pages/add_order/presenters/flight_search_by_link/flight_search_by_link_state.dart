import 'package:flutter/material.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/presentation/pages/add_order/presenters/models.dart';
import 'package:collection/collection.dart';

class FlightSearchByLinkState {
  final TextEditingController flightAwareLinkController =
      TextEditingController();
  final FocusNode flightAwareLinkFocusNode = FocusNode();
  bool flightLoading = false;

  Either<List<Flight>, SearchError> foundFlights = const Either.empty();

  Flight? get selectedFlight => foundFlights.value?.firstOrNull;
}
