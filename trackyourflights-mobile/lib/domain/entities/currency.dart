import 'package:collection/collection.dart';

class Currency {
  const Currency({
    required this.symbol,
    required this.name,
    required this.code,
  });

  final String symbol;
  final String name;
  final String code;

  static const Currency usd = Currency(symbol: '\$', name: 'USD', code: 'usd');
  static const Currency eur = Currency(symbol: '€', name: 'EUR', code: 'eur');
  static const Currency rub = Currency(symbol: '₽', name: 'RUB', code: 'rur');

  static Currency? byCode(String name) => const [usd, eur, rub]
      .firstWhereOrNull((e) => e.code.toUpperCase() == name.toUpperCase());
}
