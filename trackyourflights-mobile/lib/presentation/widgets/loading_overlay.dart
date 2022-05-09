import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    Key? key,
    required this.loading,
    required this.child,
    this.showText = true,
    this.iconSize,
  }) : super(key: key);

  final bool loading;
  final Widget child;

  final bool showText;
  final Size? iconSize;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  static const musicLinks = [
    'https://www.youtube.com/watch?v=dv13gl0a-FA',
    'https://www.youtube.com/watch?v=ncaNlxvTFzg',
    'https://www.youtube.com/watch?v=FGBhQbmPwH8',
    'https://www.youtube.com/watch?v=Z1k0bwnAKm0',
    'https://www.youtube.com/watch?v=qD9AheDpjoo',
    'https://www.youtube.com/watch?v=UbQgXeY_zi4',
    'https://www.youtube.com/watch?v=h4HJjBCjSt4',
    'https://www.youtube.com/watch?v=h4HJjBCjSt4',
    'https://www.youtube.com/watch?v=h4HJjBCjSt4',
  ];

  static final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _onLoadingSwitched(widget.loading);
  }

  @override
  void didUpdateWidget(covariant LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading != oldWidget.loading) {
      _onLoadingSwitched(widget.loading);
    }
  }

  void _onLoadingSwitched(bool loading) {
    if (widget.loading) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: widget.loading,
            child: widget.child,
          ),
          IgnorePointer(
            ignoring: !widget.loading,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: Tween<double>(begin: 0.001, end: 10)
                      .evaluate(_animationController),
                  sigmaY: Tween<double>(begin: 0.001, end: 10)
                      .evaluate(_animationController),
                ),
                child: child,
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          if (widget.showText)
            IgnorePointer(
              ignoring: !widget.loading,
              child: AnimatedOpacity(
                opacity: widget.loading ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              'Well, it\'s loading. You need to wait a bit. Maybe you want to make some tea? '
                              'Though maybe you prefer coffee. Anyway, enjoy the moment. '
                              'In case this will take toooo long, I\'ve got ',
                        ),
                        TextSpan(
                          text: 'some music',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(
                                  Uri.parse(musicLinks[
                                      _random.nextInt(musicLinks.length)]),
                                ),
                        ),
                        const TextSpan(
                          text: ' for you. ',
                        ),
                      ],
                    ),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ),
              ),
            ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: widget.loading ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Center(
                child: Lottie.asset(
                  'assets/airplane_moves.json',
                  height: widget.iconSize?.height,
                  width: widget.iconSize?.width,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
