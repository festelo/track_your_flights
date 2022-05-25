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
  final List<AddOrderFlightDto> flights;
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

class PriceDto {
  const PriceDto({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}

class AddOrderFlightDto {
  const AddOrderFlightDto({
    required this.flightId,
    required this.personsCount,
  });
  final String flightId;
  final int personsCount;

  Map<String, dynamic> toMap() {
    return {
      'flightId': flightId,
      'personsCount': personsCount,
    };
  }
}
