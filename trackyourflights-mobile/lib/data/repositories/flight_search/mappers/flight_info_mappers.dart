import 'package:trackyourflights/data/repositories/flight_search/models/flight_info.dart';

abstract class FlightInfoMappers {
  static FlightInfo fromJson(dynamic json) {
    assert(json is Map);
    return FlightInfo(
      permaLink: json['permaLink'] ?? '',
      cancelled: json['cancelled'] ?? false,
      flightStatus: json['flightStatus'] ?? 'unknown',
      origin: Waypoint(
        timeZone: json['origin']?['TZ'],
        iata: json['origin']?['iata'],
        friendlyName: json['origin']?['friendlyName'],
        friendlyLocation: json['origin']?['friendlyLocation'],
      ),
      destination: Waypoint(
        timeZone: json['destination']?['TZ'],
        iata: json['destination']?['iata'],
        friendlyName: json['destination']?['friendlyName'],
        friendlyLocation: json['destination']?['friendlyLocation'],
      ),
      gateArrivalTimes: TimeSet(
        actual: json['gateArrivalTimes']?['actual'],
        estimated: json['gateArrivalTimes']?['estimated'],
        scheduled: json['gateArrivalTimes']?['scheduled'],
      ),
      gateDepartureTimes: TimeSet(
        actual: json['gateDepartureTimes']?['actual'],
        estimated: json['gateDepartureTimes']?['estimated'],
        scheduled: json['gateDepartureTimes']?['scheduled'],
      ),
      landingTimes: TimeSet(
        actual: json['landingTimes']?['actual'],
        estimated: json['landingTimes']?['estimated'],
        scheduled: json['landingTimes']?['scheduled'],
      ),
      takeoffTimes: TimeSet(
        actual: json['takeoffTimes']?['actual'],
        estimated: json['takeoffTimes']?['estimated'],
        scheduled: json['takeoffTimes']?['scheduled'],
      ),
      aircraft: JetInfo(
        friendlyType: json['aircraft']?['friendlyType'],
        type: json['aircraft']?['type'],
      ),
    );
  }
}
