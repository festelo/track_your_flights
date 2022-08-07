import 'dart:async';
import 'dart:convert';

import 'package:trackyourflights/data/http/uri_resolver.dart';
import 'package:trackyourflights/data/repositories/history/api/mappers/order_mappers.dart';
import 'package:trackyourflights/data/ws/ws_client.dart';
import 'package:trackyourflights/domain/entities/flight.dart';
import 'package:trackyourflights/domain/entities/flight_search.dart';
import 'package:trackyourflights/domain/entities/flight_search_status_update.dart';
import 'package:trackyourflights/domain/repositories/complex_search_repository.dart';
import 'package:http/http.dart' as http;

class ComplexSearchRepositoryImpl implements ComplexSearchRepository {
  ComplexSearchRepositoryImpl({
    required this.uriResolver,
    required this.client,
    required this.wsClient,
  });

  final UriResolver uriResolver;
  final http.Client client;
  final WsClient wsClient;

  late final StreamController<FlightSearchStatusUpdate> _onStatusChange =
      StreamController.broadcast(
    onListen: _onStatusChangeOnListen,
  );

  @override
  Stream<FlightSearchStatusUpdate> get onStatusChange => _onStatusChange.stream;

  StreamSubscription? _onMessagesInSubscription;
  StreamSubscription? _onConnectSubscription;

  void _onStatusChangeOnListen() async {
    _onMessagesInSubscription?.cancel();
    _onMessagesInSubscription = wsClient.messagesIn
        .where((e) => e.channel == 'flights-search')
        .listen((e) {
      final status = FlightSearchStatus.values.byName(e.data['status']);
      final data = e.data['data'];
      Flight? flight;
      if (data != null && status == FlightSearchStatus.completed) {
        final dataList = data as List;
        if (dataList.isNotEmpty) {
          flight = FlightMappers.flightFromMap(
            Map<String, dynamic>.from(dataList.first as Map),
          );
        }
      }
      _onStatusChange.add(
        FlightSearchStatusUpdate(
          id: e.data['id'].toString(),
          status: FlightSearchStatus.values.byName(e.data['status']),
          data: flight,
          error: e.data['error']?.toString(),
          progress: status == FlightSearchStatus.progress
              ? e.data['data'] / 100
              : null,
        ),
      );
    });
    _onConnectSubscription?.cancel();
    _onConnectSubscription = wsClient.onConnect.listen((e) => _subscribe());
    _subscribe();
  }

  Future<void> _subscribe() async {
    await wsClient.sendAndWait(WsOutMessage(event: 'subscribe'));
  }

  @override
  Future<FlightSearch> createSearch({
    required String ident,
    required DateTime aproxDate,
    required String? originItea,
    required String? destItea,
    required bool? restart,
  }) async {
    final res = await client.post(
      uriResolver.uri('/flights/get/range'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'aproxDate': aproxDate.toIso8601String(),
        'ident': ident,
        'originItea': originItea,
        'destItea': destItea,
        'restart': restart ?? false,
      }),
    );
    final resJson = jsonDecode(res.body) as Map;
    return FlightSearchMappers.flightSearchFromMap(
        Map<String, dynamic>.from(resJson));
  }

  @override
  Future<void> cancelSearch(String id) async {
    await client.get(
      uriResolver.uri('/flights/get/range/stop', [QueryParam('id', id)]),
      headers: {'content-type': 'application/json'},
    );
  }

  void dispose() {
    _onMessagesInSubscription?.cancel();
    _onConnectSubscription?.cancel();
    _onStatusChange.close();
  }
}
