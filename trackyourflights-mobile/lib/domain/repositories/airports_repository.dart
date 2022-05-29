import 'package:trackyourflights/domain/entities/airport.dart';

abstract class AirportsRepository {
  Future<List<Airport>> search(String q);
}
