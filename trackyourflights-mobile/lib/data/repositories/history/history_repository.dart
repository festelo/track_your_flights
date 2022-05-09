import 'dart:convert';

import 'package:http/http.dart';
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/history/mappers/order_mappers.dart';
import 'package:trackyourflights/domain/entities/order.dart';
import 'package:trackyourflights/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({
    required this.uriResolver,
    required this.client,
  });

  final UriResolver uriResolver;
  final Client client;

  @override
  Future<List<Order>> listOrders() async {
    final res = await client.get(
      uriResolver.uri('/history/get'),
    );
    final historyList = jsonDecode(res.body) as List;
    return historyList
        .map((e) => Map<String, dynamic>.from(e['json'] as Map))
        .map(OrderMappers.orderFromMap)
        .toList();
  }

  @override
  Future<void> saveOrder(Order order) async {
    await client.post(
      uriResolver.uri('/history/add'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(OrderMappers.orderToMap(order)),
    );
  }
}
