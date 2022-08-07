import 'package:trackyourflights/domain/entities/aircraft.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';

class FlightSearchRepositoryMock implements FlightSearchRepository {
  static final _flightsList = [
    Flight(
      id: 'mock-flight',
      origin: const Waypoint(
        airport: 'Berlin Bradenburg',
        city: 'Berlin',
        iata: 'ORIG',
      ),
      destination: const Waypoint(
        airport: 'Vnukovo',
        city: 'Moscow',
        iata: 'DEST',
      ),
      landingTimes: RouteDateTime(
        actual: DateTime.now(),
        scheduled: DateTime.now(),
        estimated: DateTime.now(),
      ),
      takeoffTimes: RouteDateTime(
        actual: DateTime.now().add(const Duration(hours: 3)),
        scheduled: DateTime.now().add(const Duration(hours: 3)),
        estimated: DateTime.now().add(const Duration(hours: 3)),
      ),
      aircraft: const Aircraft(
        name: 'Boeing 737',
        shortName: 'B737',
      ),
      flightAwarePermaLink: 'flightAwarePermaLink',
    ),
  ];

  @override
  Future<List<Flight>> find(
    String ident,
    DateTime flightDate, {
    String? originItea,
    String? destItea,
    bool? checkTime,
  }) =>
      Future.value(_flightsList);

  @override
  Future<List<Flight>> findByFlightaware(String flightAwareLink) =>
      Future.value(_flightsList);

  @override
  Future<FlightPresearchResult?> presearch(String flightNumber) => Future.value(
        const FlightPresearchResult(
          description: 'Mock presearch',
          ident: 'MOCK',
        ),
      );
}
