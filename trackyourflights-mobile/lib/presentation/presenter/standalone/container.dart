import 'package:flutter/foundation.dart';
import 'package:trackyourflights/presentation/presenter/standalone/presenter_standalone.dart';

import '../presenter.dart';

typedef DisposablePresenterStandaloneProvider<Presenter extends ChangeNotifier>
    = AutoDisposeChangeNotifierProvider<Presenter>;

typedef DisposablePresenterStandaloneFamilyProvider<
        Presenter extends ChangeNotifier, Param>
    = AutoDisposeChangeNotifierProviderFamily<Presenter, Param>;

class PresenterStandaloneContainer<TPresenter extends PresenterStandalone> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterStandaloneContainer(this._presenterBuilder, {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function() _presenterBuilder;
  final bool _keepAlive;

  AutoDisposeChangeNotifierProvider<TPresenter> call() => state;

  late final DisposablePresenterStandaloneProvider<TPresenter> state =
      DisposablePresenterStandaloneProvider((ref) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder();
    presenter.load(ref);
    return presenter;
  });

  ProviderBase<TPresenter> get actions => state.notifier;
}

class PresenterStandaloneContainerWithParameter<
    TPresenter extends PresenterStandalone, TArg> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterStandaloneContainerWithParameter(
    this._presenterBuilder, {
    bool keepAlive = false,
  }) : _keepAlive = keepAlive;

  final TPresenter Function(TArg arg) _presenterBuilder;
  final bool _keepAlive;

  AutoDisposeChangeNotifierProvider<TPresenter> call(TArg arg) => state(arg);

  late final DisposablePresenterStandaloneFamilyProvider<TPresenter, TArg>
      state = DisposablePresenterStandaloneFamilyProvider((ref, arg) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder(arg);
    presenter.load(ref);
    return presenter;
  });

  ProviderBase<TPresenter> actions(TArg arg) => state(arg).notifier;
}
