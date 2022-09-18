// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> connectWebsocket(Uri uri) async {
  final socket = WebSocket(uri.toString());
  await socket.onOpen.first;
  return HtmlWebSocketChannel(socket);
}
