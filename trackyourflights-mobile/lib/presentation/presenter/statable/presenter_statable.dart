import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:trackyourflights/presentation/presenter/expansions/context_expansion.dart';
import 'package:trackyourflights/presentation/presenter/expansions/disposable_expansion.dart';

import '../base_presenter.dart';
import '../expansions/error_expansion.dart';
import '../expansions/message_expansion.dart';
import '../expansions/reactive_expansion.dart';
import '../expansions/text_editing_expansion.dart';
import 'notifier.dart';

export 'container.dart';

abstract class Presenter<TState> extends MutableNotifier<TState>
    implements BasePresenter {
  Presenter(TState state) : super(state);

  late final Ref _ref;
  Ref get ref => _ref;

  bool _initialized = false;

  void load(AutoDisposeStateNotifierProviderRef ref) {
    _ref = ref;
    final initState = this.initState;
    if (initState is Future) {
      throw Exception(
        'InitState must be sync function, making initState async can lead to unexpected behavior',
      );
    }
    initState();
    _initialized = true;
    notify();
  }

  @override
  void initState() {}

  @override
  @protected
  void notify([void Function()? fun]) {
    if (!_initialized) {
      fun?.call();
      return;
    }
    super.notify(fun);
  }
}

abstract class CompletePresenter<TStore> extends Presenter<TStore>
    with
        ReactivePresenterExpansion,
        TextEditingPresenterExpansion,
        ErrorPresenterExpansion,
        MessagePresenterExpansion,
        ContextPresenterExpansion,
        DisposableExpansion
    implements BaseCompletePresenter {
  CompletePresenter(TStore state) : super(state);
}
