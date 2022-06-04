import 'package:trackyourflights/data/ws/ws_client.dart';

class ProxyWsClient implements WsClient {
  final WsClient inner;

  ProxyWsClient(this.inner);

  @override
  Future<void> connect() => inner.connect();

  @override
  bool get connected => inner.connected;

  @override
  void dispose() => inner.dispose();

  @override
  Stream<WsInMessage> get messagesIn => inner.messagesIn;

  @override
  Stream<WsOutMessage> get messagesOut => inner.messagesOut;

  @override
  Stream<void> get onClose => inner.onClose;

  @override
  Future<void> send(WsOutMessage message) => inner.send(message);

  @override
  Future sendAndWait(WsOutMessage message) => inner.sendAndWait(message);

  @override
  Uri get url => inner.url;

  @override
  Future waitFor(String id) => inner.waitFor(id);

  @override
  Stream<void> get onConnect => inner.onConnect;
}
