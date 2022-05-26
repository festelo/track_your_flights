import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/flight_search_mappers.dart';
import 'package:trackyourflights/data/repositories/history/mappers/order_mappers.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';

class FlightSearchRepositoryImpl implements FlightSearchRepository {
  const FlightSearchRepositoryImpl({
    required this.uriResolver,
    required this.client,
  });

  final UriResolver uriResolver;
  final http.Client client;

  @override
  Future<List<Flight>> find(
    String ident,
    DateTime flightDate, {
    String? originItea,
    String? destItea,
    bool? checkTime,
  }) async {
    final res = await client.get(
      uriResolver.uri('/flights/get', [
        QueryParam('ident', ident),
        QueryParam('date', flightDate.toUtc().toIso8601String()),
        QueryParam('originItea', originItea),
        QueryParam('destItea', destItea),
        QueryParam('checkTime', checkTime?.toString())
      ]),
    );
    final resJson = jsonDecode(res.body) as List;
    final mappedRes = resJson
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(FlightMappers.flightFromMap)
        .toList();

    return mappedRes;
  }

  @override
  Future<List<Flight>> findByFlightaware(String flightAwareLink) async {
    final res = await client.get(
      uriResolver.uri('/flights/get/flightaware', [
        QueryParam('link', flightAwareLink),
      ]),
    );
    final resJson = jsonDecode(res.body) as List;
    final mappedRes = resJson
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(FlightMappers.flightFromMap)
        .toList();

    return mappedRes;
  }

  @override
  Future<FlightPresearchResult?> presearch(String flightNumber) async {
    final res = await client.get(
      uriResolver.uri('/flights/search', [
        QueryParam('q', flightNumber),
      ]),
    );
    final resJson = jsonDecode(res.body) as List;
    final mappedRes = resJson.map(FlightSearchMappers.fromJson).toList();
    final model = mappedRes.firstOrNull;
    if (model == null) return null;
    return FlightPresearchResult(
      description: model.description,
      ident: model.ident,
    );
  }
}
