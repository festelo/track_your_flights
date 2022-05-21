import 'package:trackyourflights/domain/entities/aircraft.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

class Flight {
  const Flight({
    required this.id,
    required this.origin,
    required this.destination,
    required this.landingTimes,
    required this.takeoffTimes,
    required this.aircraft,
    required this.flightAwarePermaLink,
  });

  final String id;
  final Waypoint origin;
  final Waypoint destination;
  final RouteDateTime landingTimes;
  final RouteDateTime takeoffTimes;
  final Aircraft aircraft;
  final String flightAwarePermaLink;
}

class OrderFlight {
  const OrderFlight({
    required this.flight,
    required this.personsCount,
  });

  final Flight flight;
  final int personsCount;
}
