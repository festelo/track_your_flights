import '../presenter.dart';

class PresenterStandaloneContainer<TPresenter extends PresenterStandalone> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destoyed when it's not used.
  PresenterStandaloneContainer(this._presenterBuilder, {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function() _presenterBuilder;
  final bool _keepAlive;

  late final AutoDisposeChangeNotifierProvider<TPresenter>
      _stateNotifierProvider = AutoDisposeChangeNotifierProvider((ref) {
    if (_keepAlive) ref.keepAlive();
    final presenter = _presenterBuilder();
    presenter.load(ref);
    return presenter;
  });

  StateProvider<TPresenter> call() => _stateNotifierProvider;

  StateProvider<TPresenter> get state => _stateNotifierProvider;

  PresenterProvider<TPresenter> get actions => _stateNotifierProvider.notifier;
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

  late final AutoDisposeChangeNotifierProviderFamily<TPresenter, TArg>
      _stateNotifierProvider =
      AutoDisposeChangeNotifierProviderFamily((ref, arg) {
    if (_keepAlive) ref.keepAlive();
    final presenter = _presenterBuilder(arg);
    presenter.load(ref);
    return presenter;
  });

  StateProvider<TPresenter> call(TArg arg) => _stateNotifierProvider(arg);

  StateProvider<TPresenter> state(TArg arg) => _stateNotifierProvider(arg);

  PresenterProvider<TPresenter> actions(TArg arg) =>
      _stateNotifierProvider(arg).notifier;
}
