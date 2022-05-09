import '../presenter.dart';
import 'package:flutter/widgets.dart';

mixin TextEditingPresenterExpansion on BasePresenter {
  final List<TextEditingController> _controllers = [];

  TextEditingController useTextEditingController() {
    final controller = TextEditingController();
    _controllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }
}
