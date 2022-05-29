import 'dart:convert';

import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/airports/mappers/airports_mappers.dart';
import 'package:trackyourflights/domain/entities/airport.dart';
import 'package:trackyourflights/domain/repositories/airports_repository.dart';
import 'package:http/http.dart' as http;

class AirportsRepositoryImpl implements AirportsRepository {
  const AirportsRepositoryImpl({
    required this.uriResolver,
    required this.client,
  });

  final UriResolver uriResolver;
  final http.Client client;

  @override
  Future<List<Airport>> search(String q) async {
    final res = await client.get(
      uriResolver.uri('/airports/search', [
        QueryParam('q', q),
      ]),
    );
    final resJson = jsonDecode(res.body) as List;
    final mappedRes = resJson.map(AirportsMappers.fromJson).toList();
    return mappedRes;
  }
}
