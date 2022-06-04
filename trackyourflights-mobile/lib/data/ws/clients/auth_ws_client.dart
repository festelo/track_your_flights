import 'dart:async';

import 'package:trackyourflights/data/http/token_storage.dart';
import 'package:trackyourflights/data/ws/clients/proxy_ws_client.dart';
import 'package:trackyourflights/data/ws/ws_client.dart';

class AuthWsClient extends ProxyWsClient {
  late StreamSubscription _onCloseSubscription;

  final TokenStorage tokenStorage;

  Completer<void>? _refreshCompleter;
  bool _authorized = false;

  AuthWsClient(super.inner, this.tokenStorage) : super() {
    _onCloseSubscription = onClose.listen(_onClose);
  }

  void _onClose(_) {
    _authorized = false;
  }

  FutureOr<void> _waitAuth() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      return _refreshCompleter!.future;
    }
  }

  Future<void> _auth() {
    final refreshCompleter = _refreshCompleter = Completer();

    return inner
        .sendAndWait(WsOutMessage(event: 'auth', data: {
      'token': tokenStorage.currentToken.valueOrNull,
    }))
        .then((value) {
      _authorized = value.data == 'ok';
    }).whenComplete(() => refreshCompleter.complete(null));
  }

  @override
  Future<void> send(WsOutMessage message) async {
    final future = _waitAuth();
    if (future != null) await future;
    if (!_authorized) {
      await _auth();
    }
    final response = await inner.send(message);
    return response;
  }

  @override
  Future<dynamic> sendAndWait(WsOutMessage message) async {
    if (!connected) await connect();
    await send(message);
    return waitFor(message.id);
  }

  @override
  void dispose() {
    _onCloseSubscription.cancel();
  }
}
