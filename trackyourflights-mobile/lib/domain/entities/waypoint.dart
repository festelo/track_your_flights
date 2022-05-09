import 'package:trackyourflights/domain/entities/airport_info.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';

class Waypoint {
  const Waypoint({
    required this.airport,
    required this.dateTime,
  });

  final AirportInfo airport;
  final RouteDateTime dateTime;
}
