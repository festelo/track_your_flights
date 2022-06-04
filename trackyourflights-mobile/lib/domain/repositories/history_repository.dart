import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/order.dart';

abstract class HistoryRepository {
  Future<void> saveOrder(Order order);
  Future<void> updateOrderFlight(
    String orderId,
    String oldFlightId,
    OrderFlight flight,
  );
  Future<List<Order>> listOrders();
}
