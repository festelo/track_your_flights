import 'dart:async';

import 'package:flutter/material.dart';

import '../expansions/message_expansion.dart';

class MessageBridge extends StatefulWidget {
  const MessageBridge({
    Key? key,
    required this.presenter,
    required this.child,
  }) : super(key: key);

  final MessagePresenterExpansion presenter;
  final Widget child;

  @override
  State<MessageBridge> createState() => _MessageBridgeState();
}

class _MessageBridgeState extends State<MessageBridge> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.presenter.presenterMessages.listen(_onMessage);
  }

  void _onMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
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
