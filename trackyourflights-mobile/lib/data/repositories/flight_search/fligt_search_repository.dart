import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trackyourflights/data/repositories/flight_search/mappers/datetime_mappers.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/flight_info_mappers.dart';
import 'package:trackyourflights/data/repositories/flight_search/mappers/flight_search_mappers.dart';
import 'package:trackyourflights/data/repositories/flight_search/models/flight_info.dart'
    hide Waypoint;
import 'package:trackyourflights/data/repositories/flight_search/models/flight_search.dart';
import 'package:trackyourflights/domain/entities/airplane.dart';
import 'package:trackyourflights/domain/entities/airport_info.dart';
import 'package:trackyourflights/domain/entities/flight_query_result.dart';
import 'package:trackyourflights/domain/entities/route_date_time.dart';
import 'package:trackyourflights/domain/entities/waypoint.dart';
import 'package:trackyourflights/domain/repositories/flight_search_repository.dart';

class FlightSearchRepositoryImpl implements FlightSearchRepository {
  Future<String> _getSearchToken() async {
    final response = await http.get(
      Uri.parse('https://flightaware.com/'),
      headers: {
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Language': 'en-GB,en;q=0.9,en-US;q=0.8,ru;q=0.7',
        'Cache-Control': 'max-age=0',
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.50'
      },
    );
    final regex = RegExp('<input type="hidden" name="token" value="([^"]*)"');
    final match = regex.firstMatch(response.body);
    return match?.group(1) ?? (throw Exception("Can't find search token"));
  }

  Future<String> _getLogpollToken(String historyUrl) async {
    final response = await http.get(
      Uri.parse(historyUrl),
      headers: {
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Language': 'en-GB,en;q=0.9,en-US;q=0.8,ru;q=0.7',
        'Cache-Control': 'max-age=0',
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.50'
      },
    );
    final regex = RegExp('{"TOKEN":"([^"]*)"');
    final match = regex.firstMatch(response.body);
    return match?.group(1) ?? (throw Exception("Can't find logpoll token"));
  }

  Future<List<FlightInfo>> _searchForLogpoll(String historyUrl) async {
    final token = await _getLogpollToken(historyUrl);
    final logpollResponse = await http.get(
      Uri.parse('https://flightaware.com/ajax/logpoll.rvt?token=$token'),
      headers: {
        'Cookie':
            'w_sid=305cfdef5f41d9988d8ef79370d872f21c31c0aff1c60c314374c7201b5ca3a2',
      },
    );
    final logpollResponseJson = jsonDecode(logpollResponse.body);
    final logpollResponseJsonList = (logpollResponseJson['flights'] as Map)
        .values
        .first['activityLog']['flights'] as List;
    return logpollResponseJsonList.map(FlightInfoMappers.fromJson).toList();
  }

  Future<List<FlightSearch>> _searchForFlight(String flightNumber) async {
    final flightNumberEncoded = Uri.encodeQueryComponent(flightNumber);

    final findUrl =
        'https://e1.flightcdn.com/ajax/ignoreall/omnisearch/flight.rvt?v=50&locale=en_US&searchterm=$flightNumberEncoded&q=$flightNumberEncoded';

    final findResponse = await http.get(Uri.parse(findUrl));
    final findResponseJson = jsonDecode(findResponse.body);
    final findResponseJsonList = findResponseJson['data'] as List;
    return findResponseJsonList.map(FlightSearchMappers.fromJson).toList();
  }

  @override
  Future<List<FlightQueryResult>> find(
    String flightNumber,
    DateTime flightDate,
  ) async {
    final flights = await _searchForFlight(flightNumber);
    if (flights.isEmpty) throw Exception('Can\'t find flight');
    final flight = flights.first;

    final dateStr =
        '${flightDate.year}${flightDate.month.toString().padLeft(2, "0")}${flightDate.day.toString().padLeft(2, "0")}';
    final historyUrl =
        'https://flightaware.com/live/flight/${flight.ident}/history/$dateStr/';
    final logpollResult = await _searchForLogpoll(historyUrl);

    final resultEntities = logpollResult
        .where((e) {
          final dateTime = DateTimeMappers.dateTimeFromEpochNullable(
              e.takeoffTimes.scheduled);
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
                city: entry.value.origin.friendlyLocation ?? 'Unknown',
                airport: entry.value.origin.friendlyName ?? 'Unknown',
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
                city: entry.value.destination.friendlyLocation ?? 'Unknown',
                airport: entry.value.destination.friendlyName ?? 'Unknown',
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
  Future<String?> presearch(String flightNumber) async {
    final flights = await _searchForFlight(flightNumber);
    if (flights.isEmpty) return null;
    return flights.first.description;
  }
}
