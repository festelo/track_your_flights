import 'package:trackyourflights/domain/entities/airplane.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

class Flight {
  const Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.personsCount,
    required this.airplane,
    required this.flightAwareLink,
  });

  final String id;
  final Waypoint from;
  final Waypoint to;
  final int personsCount;
  final Airplane airplane;
  final String flightAwareLink;
}
