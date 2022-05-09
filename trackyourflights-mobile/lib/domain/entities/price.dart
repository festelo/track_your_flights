import 'package:trackyourflights/domain/entities/currency.dart';

class Price {
  const Price({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final Currency currency;
}
