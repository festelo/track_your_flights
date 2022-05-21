import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';

abstract class FlightSearchRepository {
  Future<List<Flight>> find(
    String ident,
    DateTime flightDate, {
    String? originItea,
    String? destItea,
    bool? checkTime,
  });

  /// Tries to search flight number and returns its description
  Future<FlightPresearchResult?> presearch(String flightNumber);
}
