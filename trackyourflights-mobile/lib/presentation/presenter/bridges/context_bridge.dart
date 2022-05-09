import 'package:flutter/material.dart';
import 'package:trackyourflights/presentation/presenter/expansions/context_expansion.dart';

class ContextBridge extends StatefulWidget {
  const ContextBridge({
    Key? key,
    required this.presenter,
    required this.child,
  }) : super(key: key);

  final ContextPresenterExpansion presenter;
  final Widget child;

  @override
  State<ContextBridge> createState() => _ContextBridgeState();
}

class _ContextBridgeState extends State<ContextBridge> {
  @override
  void initState() {
    super.initState();
    widget.presenter.contextContainer.register(_contextResolver);
  }

  BuildContext _contextResolver() => context;

  @override
  void dispose() {
    widget.presenter.contextContainer.unregister(_contextResolver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
