import 'package:flutter/material.dart';

import 'disposable.dart';

mixin DisposableState<T extends StatefulWidget> on State<T>
    implements Disposable {
  final List<DisposableCallback> _disposables = [];

  @override
  void registerDisposable(DisposableCallback disposable) {
    _disposables.add(disposable);
  }

  @override
  void dispose() {
    for (var disposable in _disposables) {
      disposable();
    }
    super.dispose();
  }
}
