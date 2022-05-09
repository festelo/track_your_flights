import 'package:trackyourflights/domain/entities/airplane.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

class FlightQueryResult {
  const FlightQueryResult({
    required this.id,
    required this.from,
    required this.to,
    required this.airplane,
    required this.flightAwareLink,
  });

  final String id;
  final Waypoint from;
  final Waypoint to;
  final Airplane airplane;
  final String flightAwareLink;
}
