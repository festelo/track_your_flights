import 'order_flight_dto.dart';
import 'price_dto.dart';

class AddOrderRequest {
  const AddOrderRequest({
    required this.price,
    required this.orderedAt,
    required this.flights,
    required this.comment,
    required this.link,
    required this.seller,
  });

  final PriceDto price;
  final DateTime orderedAt;
  final List<OrderFlightDto> flights;
  final String? comment;
  final String? link;
  final String? seller;

  Map<String, dynamic> toMap() {
    return {
      'price': price.toMap(),
      'orderedAt': orderedAt.millisecondsSinceEpoch,
      'flights': flights.map((x) => x.toMap()).toList(),
      'comment': comment,
      'link': link,
      'seller': seller,
    };
  }
}
