import '../models/flight_search.dart';

abstract class FlightPresearchMappers {
  static FlightPresearch fromJson(dynamic json) {
    assert(json is Map);
    return FlightPresearch(
      description: json['description'],
      ident: json['ident'],
    );
  }
}
