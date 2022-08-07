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
