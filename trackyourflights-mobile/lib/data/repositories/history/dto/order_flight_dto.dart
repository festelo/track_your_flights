class OrderFlightDto {
  const OrderFlightDto({
    required this.flightId,
    required this.searchId,
    required this.personsCount,
  }) : assert(flightId != null || searchId != null);
  final String? flightId;
  final String? searchId;
  final int personsCount;

  Map<String, dynamic> toMap() {
    return {
      'flightId': flightId,
      'searchId': searchId,
      'personsCount': personsCount,
    };
  }
}
