import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectWebsocket(Uri uri) async {
  final socket = await WebSocket.connect(uri.toString());
  return IOWebSocketChannel(socket);
}
