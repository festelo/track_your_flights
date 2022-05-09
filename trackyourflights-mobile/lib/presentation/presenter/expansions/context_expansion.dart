import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:trackyourflights/presentation/presenter/presenter.dart';

mixin ContextPresenterExpansion on BasePresenter {
  final ContextContainer contextContainer = ContextContainer();

  NavigatorState? get navigator {
    final context = contextContainer.context;
    if (context == null) return null;
    return Navigator.of(context);
  }

  BuildContext? get context => contextContainer.context;

  bool get contextAvailable => contextContainer.context != null;
}

typedef ContextProvider = BuildContext Function();

class ContextContainer {
  final List<ContextProvider> _contextProviders = [];

  void register(ContextProvider contextProvider) {
    _contextProviders.add(contextProvider);
  }

  void unregister(ContextProvider contextProvider) {
    _contextProviders.remove(contextProvider);
  }

  BuildContext? get context {
    assert(() {
      if (_contextProviders.isEmpty) {
        log('No contextProviders registered. Presenter must be connected to widget tree using [MxcPage] or [MxcContextHook]');
        return true;
      }
      if (_contextProviders.length != 1) {
        log('Only one contextProvider can be registered when [perform] is used to avoid unexpected behavior');
        return true;
      }
      return true;
    }());
    return _contextProviders.last();
  }
}
