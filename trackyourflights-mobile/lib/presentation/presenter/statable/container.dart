import '../presenter.dart';

typedef StateProvider<State> = ProviderBase<State>;
typedef PresenterProvider<Presenter> = ProviderListenable<Presenter>;

class PresenterContainer<TPresenter extends Presenter<TStore>, TStore> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterContainer(this._presenterBuilder, {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function() _presenterBuilder;
  final bool _keepAlive;

  late final AutoDisposeStateNotifierProvider<TPresenter, TStore>
      _stateNotiferProvider =
      AutoDisposeStateNotifierProvider<TPresenter, TStore>((ref) {
    if (_keepAlive) {
      ref.keepAlive();
    }
    final presenter = _presenterBuilder();
    presenter.load(ref);
    return presenter;
  });

  StateProvider<TStore> get state => _stateNotiferProvider;

  PresenterProvider<TPresenter> get actions => _stateNotiferProvider.notifier;
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

  late final AutoDisposeStateNotifierProviderFamily<TPresenter, TStore, TArg>
      _stateNotiferProvider =
      AutoDisposeStateNotifierProviderFamily<TPresenter, TStore, TArg>(
          (ref, arg) {
    if (_keepAlive) {
      ref.keepAlive();
    }
    final presenter = _presenterBuilder(arg);
    presenter.load(ref);
    return presenter;
  });

  StateProvider<TStore> state(TArg arg) => _stateNotiferProvider(arg);

  PresenterProvider<TPresenter> actions(TArg arg) =>
      _stateNotiferProvider(arg).notifier;
}
