import 'package:trackyourflights/domain/entities/airport.dart';

abstract class AirportsMappers {
  static Airport fromJson(dynamic json) {
    assert(json is Map);
    return Airport(
      description: json['description'],
      icao: json['icao'],
    );
  }
}
