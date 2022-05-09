import 'package:trackyourflights/domain/entities/airplane.dart';
import 'package:trackyourflights/domain/entities/airport_info.dart';
import 'package:trackyourflights/domain/entities/currency.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/price.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';

abstract class OrderMappers {
  static Map<String, dynamic> orderToMap(Order order) {
    return {
      'id': order.id,
      'price': PriceMappers.priceToMap(order.price),
      'flights':
          order.flights.map((x) => FlightMappers.flightToMap(x)).toList(),
      'orderedAt': order.orderedAt.toUtc().toIso8601String(),
    };
  }

  static Order orderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      price: PriceMappers.priceFromMap(map['price']),
      flights: List<Flight>.from(
        map['flights']?.map((x) => FlightMappers.flightFromMap(x)),
      ),
      orderedAt: DateTime.parse(map['orderedAt']),
    );
  }
}

abstract class FlightMappers {
  static Map<String, dynamic> flightToMap(Flight flight) {
    return {
      'id': flight.id,
      'from': WaypointMappers.waypointToMap(flight.from),
      'to': WaypointMappers.waypointToMap(flight.to),
      'personsCount': flight.personsCount,
      'airplane': AirplaneMappers.airplaneToMap(flight.airplane),
      'flightAwareLink': flight.flightAwareLink,
    };
  }

  static Flight flightFromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'] ?? '',
      from: WaypointMappers.waypointFromMap(map['from']),
      to: WaypointMappers.waypointFromMap(map['to']),
      personsCount: map['personsCount']?.toInt() ?? 0,
      airplane: AirplaneMappers.airplaneFromMap(map['airplane']),
      flightAwareLink: map['flightAwareLink'],
    );
  }
}

abstract class WaypointMappers {
  static Map<String, dynamic> waypointToMap(Waypoint waypoint) {
    return {
      'airport': AirportInfoMappers.airportInfoToMap(waypoint.airport),
      'dateTime': RouteDateTimeMappers.routeDateTimeToMap(waypoint.dateTime),
    };
  }

  static Waypoint waypointFromMap(Map<String, dynamic> map) {
    return Waypoint(
      airport: AirportInfoMappers.airportInfoFromMap(map['airport']),
      dateTime: RouteDateTimeMappers.routeDateTimeFromMap(map['dateTime']),
    );
  }
}

abstract class AirportInfoMappers {
  static Map<String, dynamic> airportInfoToMap(AirportInfo info) {
    return {
      'city': info.city,
      'airport': info.airport,
    };
  }

  static AirportInfo airportInfoFromMap(Map<String, dynamic> map) {
    return AirportInfo(
      city: map['city'] ?? '',
      airport: map['airport'] ?? '',
    );
  }
}

abstract class RouteDateTimeMappers {
  static Map<String, dynamic> routeDateTimeToMap(RouteDateTime routeDateTime) {
    return {
      'actual': routeDateTime.actual?.toUtc().toIso8601String(),
      'planned': routeDateTime.planned?.toUtc().toIso8601String(),
    };
  }

  static RouteDateTime routeDateTimeFromMap(Map<String, dynamic> map) {
    return RouteDateTime(
      actual: map['actual'] != null ? DateTime.parse(map['actual']) : null,
      planned: map['planned'] != null ? DateTime.parse(map['planned']) : null,
    );
  }
}

abstract class PriceMappers {
  static Map<String, dynamic> priceToMap(Price price) {
    return {
      'amount': price.amount,
      'currency': price.currency.code,
    };
  }

  static Price priceFromMap(Map<String, dynamic> map) {
    return Price(
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: Currency.byCode(map['currency'])!,
    );
  }
}

abstract class AirplaneMappers {
  static Map<String, dynamic> airplaneToMap(Airplane airplane) {
    return {
      'name': airplane.name,
      'shortName': airplane.shortName,
    };
  }

  static Airplane airplaneFromMap(Map<String, dynamic> map) {
    return Airplane(
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
    );
  }
}
