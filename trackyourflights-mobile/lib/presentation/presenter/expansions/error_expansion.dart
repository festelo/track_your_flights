import 'dart:async';
import 'dart:developer';

import '../presenter.dart';

mixin ErrorPresenterExpansion on BasePresenter {
  late final StreamController<String> _errorController =
      StreamController.broadcast();

  Stream<String> get presenterErrors => _errorController.stream;

  void addError(dynamic error, [StackTrace? stackTrace]) {
    String errorString;
    // ignore: avoid_dynamic_calls
    try {
      // ignore: avoid_dynamic_calls
      errorString = error.message.toString();
    } on NoSuchMethodError {
      errorString = error.toString();
    }
    _errorController.add(errorString);
    log('Error catched', error: error, stackTrace: stackTrace);
  }

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }
}
