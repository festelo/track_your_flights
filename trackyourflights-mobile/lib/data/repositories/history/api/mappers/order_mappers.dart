import 'package:trackyourflights/domain/entities/aircraft.dart';
import 'package:trackyourflights/domain/entities/currency.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/price.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

abstract class OrderMappers {
  static Order orderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'].toString(),
      price: PriceMappers.priceFromMap(map['price']),
      orderedAt: DateTime.parse(map['orderedAt']),
      flights: List<OrderFlight>.from(
        map['flights']?.map((x) => OrderFlightMappers.flightFromMap(x)),
      ),
      link: map['link'],
      comment: map['comment'],
      seller: map['seller'],
    );
  }
}

abstract class OrderFlightMappers {
  static OrderFlight flightFromMap(Map<String, dynamic> map) {
    return OrderFlight(
      id: map['id']?.toString(),
      trackExists: map['trackExists'],
      flightOrSearch: map['flight'] == null
          ? FlightOrSearch.search(
              FlightSearchMappers.flightSearchFromMap(
                map['flightSearch'],
              ),
            )
          : FlightOrSearch.flight(
              FlightMappers.flightFromMap(map['flight']),
            ),
      personsCount: map['personsCount']?.toInt() ?? 0,
    );
  }
}

abstract class FlightMappers {
  static Flight flightFromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'].toString(),
      ident: map['ident'].toString(),
      origin: WaypointMappers.waypointFromMap(map['origin']),
      destination: WaypointMappers.waypointFromMap(map['destination']),
      aircraft: AircraftMappers.aircraftFromMap(map['aircraft']),
      landingTimes:
          RouteDateTimeMappers.routeDateTimeFromMap(map['landingTimes']),
      takeoffTimes:
          RouteDateTimeMappers.routeDateTimeFromMap(map['takeoffTimes']),
      flightAwarePermaLink: map['flightAwarePermaLink'],
    );
  }
}

abstract class WaypointMappers {
  static Waypoint waypointFromMap(Map<String, dynamic> map) {
    if (map['iata'] != null && map['iata'].toString().isEmpty) {
      map['iata'] = null;
    }
    return Waypoint(
      city: map['city'] ?? '',
      airport: map['airport'] ?? '',
      iata: map['iata'],
    );
  }
}

abstract class RouteDateTimeMappers {
  static RouteDateTime routeDateTimeFromMap(Map<String, dynamic> map) {
    return RouteDateTime(
      actual: map['actual'] != null ? DateTime.parse(map['actual']) : null,
      scheduled:
          map['scheduled'] != null ? DateTime.parse(map['scheduled']) : null,
      estimated:
          map['estimated'] != null ? DateTime.parse(map['estimated']) : null,
    );
  }
}

abstract class PriceMappers {
  static Price priceFromMap(Map<String, dynamic> map) {
    return Price(
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: Currency.byCode(map['currency'])!,
    );
  }
}

abstract class AircraftMappers {
  static Aircraft aircraftFromMap(Map<String, dynamic> map) {
    return Aircraft(
      name: map['friendlyType'] ?? '',
      shortName: map['type'] ?? '',
    );
  }
}

abstract class FlightSearchMappers {
  static FlightSearch flightSearchFromMap(Map<String, dynamic> map) {
    final data = map['data'];
    Flight? flight;
    if (data != null && data is List) {
      if (data.isNotEmpty) {
        flight = FlightMappers.flightFromMap(
          Map<String, dynamic>.from(data.first as Map),
        );
      }
    }
    return FlightSearch(
      id: map['id']?.toString() ?? '',
      ident: map['ident'] ?? '',
      aproxDate: DateTime.parse(map['aproxDate']),
      minutesRange: map['minutesRange'],
      originItea: map['originItea'],
      destItea: map['destItea'],
      state: map['state'] ?? '',
      progress: map['progress'] != null ? map['progress'] / 100 : null,
      error: map['error'],
      flight: flight,
    );
  }
}
