import 'package:trackyourflights/domain/entities/order.dart';

abstract class HistoryRepository {
  Future<void> saveOrder(Order order);
  Future<List<Order>> listOrders();
}
