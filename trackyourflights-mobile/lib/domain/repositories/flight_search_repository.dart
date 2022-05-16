import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/entities/flight_query_result.dart';

abstract class FlightSearchRepository {
  Future<List<FlightQueryResult>> find(String ident, DateTime flightDate);

  /// Tries to search flight number and returns its description
  Future<FlightPresearchResult?> presearch(String flightNumber);
}
