import 'dart:async';
import 'dart:developer';

import '../presenter.dart';

mixin MessagePresenterExpansion on BasePresenter {
  late final StreamController<String> _messageController =
      StreamController.broadcast();

  Stream<String> get presenterMessages => _messageController.stream;

  void addMessage(String message) {
    _messageController.add(message);
    log(message);
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}
