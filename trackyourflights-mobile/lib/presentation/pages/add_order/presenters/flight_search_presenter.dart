import 'dart:async';

import 'package:trackyourflights/domain/entities/flight.dart';

abstract class FlightSearchPresenter {
  void initState() {}
  String? validate();
  String? get preview;
  FutureOr<FlightOrSearch> flightOrSearch();
  void dispose() {}
}
