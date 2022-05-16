import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/datetime_mappers.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/flight_info_mappers.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/flight_search_mappers.dart';
import 'package:trackyourflights/domain/entities/airplane.dart';
import 'package:trackyourflights/domain/entities/airport_info.dart';
import 'package:trackyourflights/domain/entities/flight_presearch_result.dart';
import 'package:trackyourflights/domain/entities/flight_query_result.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';

class FlightSearchRepositoryImpl implements FlightSearchRepository {
  const FlightSearchRepositoryImpl({
    required this.uriResolver,
    required this.client,
  });

  final UriResolver uriResolver;
  final http.Client client;

  @override
  Future<List<FlightQueryResult>> find(
    String ident,
    DateTime flightDate,
  ) async {
    final res = await client.get(
      uriResolver.uri('/flights/get', [
        QueryParam('ident', ident),
        QueryParam('date', flightDate.toUtc().toIso8601String()),
      ]),
    );
    final resJson = jsonDecode(res.body) as List;
    final mappedRes = resJson.map(FlightInfoMappers.fromJson).toList();

    final resultEntities = mappedRes
        .where((e) {
          final dateTime = DateTimeMappers.dateTimeFromEpochNullable(
            e.takeoffTimes.scheduled,
          );
          return dateTime?.year == flightDate.year &&
              dateTime?.month == flightDate.month &&
              dateTime?.day == flightDate.day;
        })
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => FlightQueryResult(
            id: entry.value.permaLink,
            flightAwareLink: entry.value.permaLink,
            from: Waypoint(
              airport: AirportInfo(
                city: entry.value.origin.city ?? 'Unknown',
                airport: entry.value.origin.airport ?? 'Unknown',
              ),
              dateTime: RouteDateTime(
                actual: DateTimeMappers.dateTimeFromEpochNullable(
                  entry.value.takeoffTimes.actual,
                ),
                planned: DateTimeMappers.dateTimeFromEpochNullable(
                  entry.value.takeoffTimes.scheduled,
                ),
              ),
            ),
            to: Waypoint(
              airport: AirportInfo(
                city: entry.value.destination.city ?? 'Unknown',
                airport: entry.value.destination.airport ?? 'Unknown',
              ),
              dateTime: RouteDateTime(
                actual: DateTimeMappers.dateTimeFromEpochNullable(
                  entry.value.landingTimes.actual,
                ),
                planned: DateTimeMappers.dateTimeFromEpochNullable(
                  entry.value.landingTimes.scheduled,
                ),
              ),
            ),
            airplane: Airplane(
              name: entry.value.aircraft.friendlyType ?? 'Unknown',
              shortName: entry.value.aircraft.type ?? 'Unknown',
            ),
          ),
        );

    return resultEntities
        .where((e) =>
            e.from.dateTime.planned?.year == flightDate.year &&
            e.from.dateTime.planned?.month == flightDate.month &&
            e.from.dateTime.planned?.day == flightDate.day)
        .toList();
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
