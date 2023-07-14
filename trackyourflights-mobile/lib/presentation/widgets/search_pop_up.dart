import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

RelativePopupController showRelativePopup(
  BuildContext context, {
  required Widget Function(BuildContext ctx, Rect rect) builder,
}) {
  final host = RelativePopupHost.maybeOf(context)!;
  final entry = OverlayEntry(
    builder: (ctx) => RelativePopup(
      builder: builder,
      host: host,
    ),
  );
  Overlay.of(context).insert(entry);
  return RelativePopupController(entry);
}

class RelativePopupController {
  RelativePopupController(this._entry);
  final OverlayEntry _entry;

  void hide() {
    _entry.remove();
  }
}

class RelativePopupHost extends StatefulWidget {
  const RelativePopupHost({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  static RelativePopupHostState? maybeOf(BuildContext context) {
    final RelativePopupHostState? result =
        context.findAncestorStateOfType<RelativePopupHostState>();
    return result;
  }

  @override
  State<RelativePopupHost> createState() => RelativePopupHostState();
}

class RelativePopupHostState extends State<RelativePopupHost>
    with SingleTickerProviderStateMixin {
  late final StreamController<Matrix4> _onTransformUpdateController =
      StreamController.broadcast(
    onListen: _startTicker,
    onCancel: _stopTicker,
  );

  late final Ticker _ticker;
  Matrix4? _oldTransform;

  Stream<Matrix4> get onTransformUpdate => _onTransformUpdateController.stream;
  Matrix4 get transform =>
      (_oldTransform ??= context.findRenderObject()!.getTransformTo(null));

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  void _startTicker() {
    _ticker.start();
  }

  void _stopTicker() {
    _ticker.stop();
  }

  void _tick(Duration elapsed) {
    final transform = context.findRenderObject()?.getTransformTo(null);
    if (transform == _oldTransform || transform == null) return;
    _oldTransform = transform;
    _onTransformUpdateController.add(transform);
  }

  @override
  void dispose() {
    _onTransformUpdateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: widget.builder);
  }
}

class RelativePopup extends StatefulWidget {
  const RelativePopup({
    Key? key,
    required this.host,
    required this.builder,
  }) : super(key: key);

  final RelativePopupHostState host;
  final Widget Function(BuildContext ctx, Rect rect) builder;

  @override
  State<RelativePopup> createState() => _RelativePopupState();
}

class _RelativePopupState extends State<RelativePopup> {
  late Rect _parentRect;
  StreamSubscription? _hostSubscription;

  @override
  void initState() {
    super.initState();
    recalculateWidgetRect(widget.host.transform);
    _hostSubscription =
        widget.host.onTransformUpdate.listen(recalculateWidgetRect);
  }

  void recalculateWidgetRect(Matrix4 transform) {
    final translation = transform.getTranslation();
    final offset = Offset(translation.x, translation.y);
    _parentRect = (widget.host.context.findRenderObject() as RenderObject)
        .paintBounds
        .shift(offset);
    setState(() {});
  }

  @override
  void dispose() {
    _hostSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          widget.builder(context, _parentRect),
        ],
      ),
    );
  }
}
