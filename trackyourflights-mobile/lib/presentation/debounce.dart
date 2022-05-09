import 'dart:async';

import 'package:trackyourflights/presentation/nonce.dart';

class Debounce {
  Debounce([this.duration = const Duration(milliseconds: 300)]);

  final Duration duration;
  final Nonce _nonce = Nonce();

  Timer? _debounce;

  void exec(void Function(int) fun) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(duration, () {
      fun(_nonce.increase());
    });
  }

  bool shouldApplyValue(int nonce) => _nonce.shouldApplyValue(nonce);
}
