import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:rxdart/subjects.dart';

import 'ws_message.dart';
export 'ws_message.dart';

import 'ws_client_connect.dart'
    if (dart.library.io) 'ws_client_connect.io.dart'
    if (dart.library.html) 'ws_client_connect.html.dart';

class WsClient {
  final Uri url;

  WsClient(this.url);

  WebSocketChannel? _socket;

  final Subject<WsInMessage> _messagesIn = BehaviorSubject();

  Stream<WsInMessage> get messagesIn => _messagesIn;

  final Subject<WsOutMessage> _messagesOut = BehaviorSubject();
  Stream<WsOutMessage> get messagesOut => _messagesOut;

  final StreamController<void> _onClose = StreamController.broadcast();
  Stream<void> get onClose => _onClose.stream;

  final StreamController<void> _onConnect = StreamController.broadcast();
  Stream<void> get onConnect => _onConnect.stream;

  bool get connected => _socket != null;

  StreamSubscription? _onCloseSubscription;

  Completer<void>? _connectCompleter;

  Future<void> connect() async {
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      return await _connectCompleter!.future;
    }
    _connectCompleter = Completer();
    for (var i = 0;; i++) {
      try {
        if (_socket != null) {
          await _socket!.sink.close();
        }
        _socket = await connectWebsocket(url);
        _onConnect.add(null);
        _onCloseSubscription?.cancel();
        _onCloseSubscription = _socket?.stream.listen(
          (dynamic message) {
            final dynamic jsonMessage = jsonDecode(message.toString());
            if (jsonMessage is! Map) return;
            final wsInMessage =
                WsInMessage.fromMap(Map<String, dynamic>.from(jsonMessage));
            _messagesIn.add(wsInMessage);
          },
          onDone: () {
            log('WS Done');
            _socket = null;
            _onClose.add(null);
            connect();
          },
          onError: (e) {
            log('WS Error');
            _socket = null;
            _onClose.add(null);
            connect();
          },
        );
        break;
      } catch (e, s) {
        final duration = Duration(seconds: min(5 * (i + 1), 30));
        log(
          'WebSocket connecting error... Trying again in $duration',
          error: e,
          stackTrace: s,
        );
        await Future.delayed(duration);
      }
    }
    _connectCompleter!.complete(null);
  }

  Future<void> send(WsOutMessage message) async {
    final encodedRequest = jsonEncode(
      message.toMap(),
      toEncodable: (dynamic e) => e is Set ? e.toList() : e.toJson(),
    );
    _socket!.sink.add(encodedRequest);
    _messagesOut.add(message);
  }

  Future<dynamic> waitFor(String id) {
    final responseFuture = messagesIn.firstWhere((e) => e.id == id);

    return Future.any<dynamic>([
      Future<dynamic>.delayed(
        const Duration(seconds: 30),
        () => Future<dynamic>.error(TimeoutException('WS Timeout')),
      ),
      responseFuture,
    ]);
  }

  Future<dynamic> sendAndWait(WsOutMessage message) async {
    if (!connected) await connect();
    await send(message);
    return waitFor(message.id);
  }

  void dispose() {
    _onCloseSubscription?.cancel();
    _messagesIn.close();
    _messagesOut.close();
    _onClose.close();
  }
}
