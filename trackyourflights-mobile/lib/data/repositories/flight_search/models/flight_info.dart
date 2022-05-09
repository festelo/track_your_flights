class FlightInfo {
  FlightInfo({
    required this.permaLink,
    required this.landingTimes,
    required this.takeoffTimes,
    required this.gateArrivalTimes,
    required this.gateDepartureTimes,
    required this.cancelled,
    required this.origin,
    required this.destination,
    required this.aircraft,
    required this.flightStatus,
  });

  final String permaLink;

  final TimeSet landingTimes;
  final TimeSet takeoffTimes;
  final TimeSet gateArrivalTimes;
  final TimeSet gateDepartureTimes;

  final bool cancelled;

  final Waypoint origin;
  final Waypoint destination;

  final JetInfo aircraft;

  final String? flightStatus;
}

class TimeSet {
  TimeSet({
    required this.actual,
    required this.estimated,
    required this.scheduled,
  });

  final int? actual;
  final int? estimated;
  final int? scheduled;
}

class JetInfo {
  JetInfo({
    required this.friendlyType,
    required this.type,
  });

  final String? friendlyType;
  final String? type;
}

class Waypoint {
  Waypoint({
    required this.timeZone,
    required this.iata,
    required this.friendlyName,
    required this.friendlyLocation,
  });

  final String? timeZone;
  final String? iata;
  final String? friendlyName;
  final String? friendlyLocation;
}
