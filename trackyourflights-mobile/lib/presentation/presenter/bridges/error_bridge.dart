import 'dart:async';

import 'package:flutter/material.dart';

import '../expansions/error_expansion.dart';

class ErrorBridge extends StatefulWidget {
  const ErrorBridge({
    Key? key,
    required this.presenter,
    required this.child,
  }) : super(key: key);

  final ErrorPresenterExpansion presenter;
  final Widget child;

  @override
  State<ErrorBridge> createState() => _ErrorBridgeState();
}

class _ErrorBridgeState extends State<ErrorBridge> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.presenter.presenterErrors.listen(_onError);
  }

  void _onError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
