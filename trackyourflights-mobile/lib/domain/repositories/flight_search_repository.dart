import 'package:trackyourflights/domain/entities/flight_query_result.dart';

abstract class FlightSearchRepository {
  Future<List<FlightQueryResult>> find(
      String flightNumber, DateTime flightDate);

  /// Tries to search flight number and returns its description
  Future<String?> presearch(String flightNumber);
}
