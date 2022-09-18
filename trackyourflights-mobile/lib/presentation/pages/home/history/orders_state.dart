import 'package:equatable/equatable.dart';
import 'package:trackyourflights/domain/entities/order.dart';

class OrdersState with EquatableMixin {
  List<Order>? orders;
  Order? selectedOrder;

  @override
  List<Object?> get props => [orders, selectedOrder];
}
