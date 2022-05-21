import 'dart:async';

typedef DisposableCallback = FutureOr<void> Function();

abstract class Disposable {
  void registerDisposable(DisposableCallback disposable);
}
