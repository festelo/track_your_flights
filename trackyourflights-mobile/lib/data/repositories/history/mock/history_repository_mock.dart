import 'package:trackyourflights/domain/entities/aircraft.dart';
import 'package:trackyourflights/domain/entities/currency.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/price.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';
import 'package:trackyourflights/domain/repositories/history_repository.dart';

class HistoryRepositoryMock implements HistoryRepository {
  @override
  Future<List<Order>> listOrders() => Future.value([
        for (var i = 0; i < 10; i++)
          Order(
            id: 'mock-$i',
            price: const Price(amount: 100, currency: Currency.eur),
            flights: [
              OrderFlight(
                id: 'flight-1-1',
                personsCount: 2,
                trackExists: true,
                flightOrSearch: FlightOrSearch.flight(
                  Flight(
                    id: 'mock-flight',
                    ident: 'ident',
                    origin: const Waypoint(
                      airport: 'Berlin Bradenburg',
                      city: 'Berlin',
                      iata: 'ORIG',
                    ),
                    destination: const Waypoint(
                      airport: 'Vnukovo',
                      city: 'Moscow',
                      iata: 'DEST',
                    ),
                    landingTimes: RouteDateTime(
                      actual: DateTime.now(),
                      scheduled: DateTime.now(),
                      estimated: DateTime.now(),
                    ),
                    takeoffTimes: RouteDateTime(
                      actual: DateTime.now().add(Duration(hours: -8 * (i + 1))),
                      scheduled: DateTime.now().add(const Duration(hours: 3)),
                      estimated: DateTime.now().add(const Duration(hours: 3)),
                    ),
                    aircraft: const Aircraft(
                      name: 'Boeing 737',
                      shortName: 'B737',
                    ),
                    flightAwarePermaLink: 'flightAwarePermaLink',
                  ),
                ),
              ),
            ],
            orderedAt: DateTime.now().add(Duration(hours: -10 * (i + 1))),
            comment: 'no comments',
            link: 'https://nolink.com/',
            seller: 'no seller',
          ),
      ]);

  @override
  Future<void> saveOrder(Order order) => Future.value();

  @override
  Future<void> updateOrderFlight(
    String orderId,
    String oldFlightId,
    OrderFlight flight,
  ) =>
      Future.value();
}
