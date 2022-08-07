import 'order_flight_dto.dart';

class ChangeOrderRequest {
  const ChangeOrderRequest({
    required this.orderId,
    required this.oldFlightId,
    required this.flight,
  });

  final String orderId;
  final String oldFlightId;
  final OrderFlightDto flight;

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'oldFlightId': oldFlightId,
      'flight': flight.toMap(),
    };
  }
}
