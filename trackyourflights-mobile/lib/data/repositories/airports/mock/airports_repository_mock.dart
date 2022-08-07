import 'package:trackyourflights/domain/entities/airport.dart';
import 'package:trackyourflights/domain/repositories/airports_repository.dart';

class AirportsRepositoryMock implements AirportsRepository {
  @override
  Future<List<Airport>> search(String q) => Future.value(
        [
          const Airport(description: 'description', icao: 'icao'),
        ],
      );
}
