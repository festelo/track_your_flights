import 'dart:async';

final AppNotifier appNotifier = AppNotifier();

class AppNotifier {
  final StreamController<dynamic> _controller = StreamController.broadcast();

  Stream<dynamic> get events => _controller.stream;

  void push(dynamic event) {
    _controller.add(event);
  }
}

class OrdersModifiedEvent {}

class OrderAddedEvent extends OrdersModifiedEvent {}

class OrderChangedEvent extends OrdersModifiedEvent {}
