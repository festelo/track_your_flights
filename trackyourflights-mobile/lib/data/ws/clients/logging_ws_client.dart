import 'dart:async';
import 'dart:developer';

import 'package:trackyourflights/data/ws/clients/proxy_ws_client.dart';
import 'package:trackyourflights/data/ws/ws_message.dart';

class LoggingWsClient extends ProxyWsClient {
  late StreamSubscription _messagesInSubcription;
  late StreamSubscription _messagesOutSubcription;

  LoggingWsClient(super.inner) : super() {
    _messagesInSubcription = messagesIn.listen(_onMessageIn);
    _messagesOutSubcription = messagesOut.listen(_onMessageOut);
  }

  void _onMessageIn(WsInMessage m) {
    log('''
>>>>>>>>> IN
id: ${m.id}
channel: ${m.channel}
${m.data}
>>>>>>>>>
    ''');
  }

  void _onMessageOut(WsOutMessage m) {
    log('''
<<<<<<<< OUT
id: ${m.id}
event: ${m.event}
${m.data}
<<<<<<<<
    ''');
  }

  @override
  void dispose() {
    _messagesInSubcription.cancel();
    _messagesOutSubcription.cancel();
    super.dispose();
  }
}
