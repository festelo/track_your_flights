import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trackyourflights/presentation/presenter/expansions/context_expansion.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

import '../expansions/error_expansion.dart';
import '../expansions/message_expansion.dart';
import '../expansions/reactive_expansion.dart';
import '../expansions/text_editing_expansion.dart';

export 'container.dart';

abstract class PresenterStandalone extends ChangeNotifier
    implements BasePresenter {
  late final Ref _ref;
  Ref get ref => _ref;

  void load(AutoDisposeChangeNotifierProviderRef ref) {
    _ref = ref;
    final initState = this.initState;
    if (initState is Future) {
      throw Exception(
        'InitState must be sync function, making initState async can lead to unexpected behavior',
      );
    }
    initState();
    notify();
  }

  @override
  void initState() {}

  @override
  @protected
  void notify([void Function()? fun]) {
    fun?.call();
    notifyListeners();
  }
}

abstract class CompletePresenterStandalone extends PresenterStandalone
    with
        ReactivePresenterExpansion,
        TextEditingPresenterExpansion,
        ErrorPresenterExpansion,
        MessagePresenterExpansion,
        ContextPresenterExpansion
    implements BaseCompletePresenter {}
