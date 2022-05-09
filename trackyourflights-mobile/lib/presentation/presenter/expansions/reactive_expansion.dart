import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../presenter.dart';

mixin ReactivePresenterExpansion on BasePresenter {
  final List<StreamSubscription> _listenables = [];
  final Map<String, StreamSubscription> _namedListenables = {};
  int _listenRefCounter = 0;

  void listenRef<T1, T2>(
    WidgetRef ref,
    ProviderListenable<T1> provider,
    Stream<T2> Function(T1) mapper,
    void Function(T2) onData,
  ) {
    final counter = _listenRefCounter++;
    ref.listen<T1>(provider, (_, next) {
      listen<T2>(mapper(next), onData, name: '_listen_ref_$counter');
    });
  }

  StreamSubscription listen<T>(
    Stream<T> stream,
    void Function(T) onData, {
    String? name,
    void Function(dynamic, StackTrace)? onError,
  }) {
    StreamSubscription sub;
    if (stream is ValueStream<T> && stream.hasValue) {
      onData(stream.value);
      sub = stream.skip(1).listen(
            onData,
            onError: onError,
          );
    } else {
      sub = stream.listen(
        onData,
        onError: onError,
      );
    }
    _listenables.add(sub);
    if (name != null) {
      _namedListenables[name]?.cancel();
      _namedListenables[name] = sub;
    }
    return sub;
  }

  @override
  void dispose() {
    for (final l in _listenables) {
      l.cancel();
    }
    super.dispose();
  }
}
