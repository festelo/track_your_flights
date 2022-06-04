import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text;

  @override
  PrimaryButtonState createState() => PrimaryButtonState();
}

class PrimaryButtonState extends State<PrimaryButton> {
  static const Duration _errorDuration = Duration(seconds: 3);
  static const Duration _animationDuration = Duration(milliseconds: 400);

  void addError(String error) {
    setState(() {
      _errorQueue.add(error);
    });
    Timer(
      _errorDuration,
      _onTimerFinish,
    );
  }

  void _onTimerFinish() {
    _errorQueue.removeFirst();
    if (mounted) {
      setState(() {});
    }
  }

  String? get _error => _errorQueue.firstOrNull;
  final ListQueue<String> _errorQueue = ListQueue();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: _error == null
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
        ),
        alignment: Alignment.center,
        duration: _animationDuration,
        child: Text(
          _error == null ? widget.text : _error!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
