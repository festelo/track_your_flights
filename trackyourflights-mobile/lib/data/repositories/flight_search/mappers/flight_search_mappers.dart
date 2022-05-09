import 'package:trackyourflights/data/repositories/flight_search/models/flight_search.dart';

abstract class FlightSearchMappers {
  static FlightSearch fromJson(dynamic json) {
    assert(json is Map);
    return FlightSearch(
      description: json['description'],
      ident: json['ident'],
    );
  }
}
