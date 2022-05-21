import 'package:trackyourflights/presentation/disposables/disposable.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

mixin DisposableExpansion on BasePresenter implements Disposable {
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
