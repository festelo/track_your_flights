import 'package:equatable/equatable.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/price.dart';

class Order with EquatableMixin {
  const Order({
    required this.id,
    required this.price,
    required this.flights,
    required this.orderedAt,
    required this.comment,
    required this.link,
    required this.seller,
  });

  final String id;
  final Price price;
  final List<OrderFlight> flights;
  final DateTime orderedAt;
  final String? comment;
  final String? link;
  final String? seller;

  @override
  List<Object?> get props =>
      [id, price, flights, orderedAt, comment, link, seller];
}
