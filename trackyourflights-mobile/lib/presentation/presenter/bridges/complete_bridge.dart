import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/presenter/bridges/context_bridge.dart';

import '../presenter.dart';
import 'error_bridge.dart';
import 'message_bridge.dart';

class CompleteBridge extends StatelessWidget {
  const CompleteBridge({
    Key? key,
    required this.presenter,
    required this.child,
  }) : super(key: key);

  final BaseCompletePresenter presenter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ErrorBridge(
      presenter: presenter,
      child: MessageBridge(
        presenter: presenter,
        child: ContextBridge(
          presenter: presenter,
          child: child,
        ),
      ),
    );
  }
}
