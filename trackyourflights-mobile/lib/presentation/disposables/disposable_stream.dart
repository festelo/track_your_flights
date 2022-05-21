import 'dart:async';

import 'disposable.dart';

extension DisposableStream on StreamSubscription {
  void disposeWith(Disposable disposable) =>
      disposable.registerDisposable(cancel);
}
