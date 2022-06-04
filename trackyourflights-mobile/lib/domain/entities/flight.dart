import 'package:equatable/equatable.dart';
import 'package:trackyourflights/domain/entities/aircraft.dart';
import 'package:trackyourflights/domain/entities/either.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

class Flight with EquatableMixin {
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

  @override
  List<Object?> get props => [
        id,
        origin,
        destination,
        landingTimes,
        takeoffTimes,
        aircraft,
        flightAwarePermaLink,
      ];
}

class FlightOrSearch extends Or<Flight, FlightSearch> with EquatableMixin {
  FlightOrSearch.flight(Flight super.first) : super.first();
  FlightOrSearch.search(FlightSearch super.second) : super.second();

  Flight? get flight => super.first;
  FlightSearch? get search => super.second;

  @override
  List<Object?> get props => [flight, search];
}

class OrderFlight with EquatableMixin {
  const OrderFlight({
    required this.id,
    required this.flightOrSearch,
    required this.personsCount,
    required this.trackExists,
  });

  final String? id;
  final FlightOrSearch flightOrSearch;
  final int personsCount;
  final bool trackExists;

  @override
  List<Object?> get props => [id, flightOrSearch, personsCount, trackExists];
}
