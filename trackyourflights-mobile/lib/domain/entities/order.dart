import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/price.dart';

class Order {
  const Order({
    required this.id,
    required this.price,
    required this.flights,
    required this.orderedAt,
  });

  final String id;
  final Price price;
  final List<Flight> flights;
  final DateTime orderedAt;
}
