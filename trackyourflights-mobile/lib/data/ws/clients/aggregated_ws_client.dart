import 'dart:async';

import 'package:trackyourflights/data/ws/clients/proxy_ws_client.dart';
import 'package:trackyourflights/data/ws/ws_client.dart';

class AggregatedWsClient extends ProxyWsClient {
  AggregatedWsClient._(super.innerClient) : super();

  factory AggregatedWsClient(
    WsClient baseClient,
    List<WsClient Function(WsClient)> innerClients,
  ) {
    var curClient = baseClient;
    for (final constructor in innerClients) {
      curClient = constructor(curClient);
    }
    return AggregatedWsClient._(curClient);
  }
}
