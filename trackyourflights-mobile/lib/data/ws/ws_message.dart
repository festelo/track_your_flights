import 'package:trackyourflights/repositories.dart';

class WsInMessage {
  WsInMessage(this.id, this.channel, this.data);

  final String? id;
  final String? channel;
  final dynamic data;

  factory WsInMessage.fromMap(Map<String, dynamic> map) {
    return WsInMessage(
      map['id'],
      map['channel'],
      map['data'],
    );
  }
}

class WsOutMessage {
  WsOutMessage({
    String? id,
    required this.event,
    this.data = const {},
  })  : id = id ?? uuid,
        assert(!data.containsKey('id'));

  final String id;
  final String event;
  final Map<String, dynamic> data;

  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'data': {
        ...data,
        'id': id,
      }
    };
  }
}
