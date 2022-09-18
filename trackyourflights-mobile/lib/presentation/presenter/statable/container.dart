import '../presenter.dart';

typedef DisposablePresenterProvider<Presenter extends StateNotifier<State>,
        State>
    = AutoDisposeStateNotifierProvider<Presenter, State>;

typedef DisposablePresenterFamilyProvider<
        Presenter extends StateNotifier<State>, State, Param>
    = AutoDisposeStateNotifierProviderFamily<Presenter, State, Param>;

typedef PresenterProvider<Presenter extends StateNotifier<State>, State>
    = StateNotifierProvider<Presenter, State>;

class PresenterContainer<TPresenter extends Presenter<TStore>, TStore> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterContainer(this._presenterBuilder, {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function() _presenterBuilder;
  final bool _keepAlive;

  late final DisposablePresenterProvider<TPresenter, TStore> state =
      DisposablePresenterProvider((ref) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder();
    presenter.load(ref);
    return presenter;
  });

  ProviderBase<TPresenter> get actions => state.notifier;
}

class PresenterContainerWithParameter<TPresenter extends Presenter<TStore>,
    TStore, TArg> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterContainerWithParameter(
    this._presenterBuilder, {
    bool keepAlive = false,
  }) : _keepAlive = keepAlive;

  final TPresenter Function(TArg arg) _presenterBuilder;
  final bool _keepAlive;

  late final DisposablePresenterFamilyProvider<TPresenter, TStore, TArg> state =
      DisposablePresenterFamilyProvider((ref, arg) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder(arg);
    presenter.load(ref);
    return presenter;
  });

  ProviderBase<TPresenter> actions(TArg arg) => state(arg).notifier;
}
