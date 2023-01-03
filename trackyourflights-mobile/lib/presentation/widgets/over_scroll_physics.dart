import 'dart:math';

import 'package:flutter/material.dart';

class OverScrollPhysics extends AlwaysScrollableScrollPhysics {
  const OverScrollPhysics({super.parent});

  ScrollMetrics expandScrollMetrics(ScrollMetrics position) {
    return FixedScrollMetrics(
      pixels: position.pixels,
      axisDirection: position.axisDirection,
      minScrollExtent: min(position.minScrollExtent, position.pixels),
      maxScrollExtent: max(position.maxScrollExtent, position.pixels),
      viewportDimension: position.viewportDimension,
    );
  }

  @override
  OverScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OverScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(
      expandScrollMetrics(position),
      offset,
    );
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return super.shouldAcceptUserOffset(expandScrollMetrics(position));
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    return super.adjustPositionForNewDimensions(
      oldPosition: expandScrollMetrics(oldPosition),
      newPosition: expandScrollMetrics(newPosition),
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return super.applyBoundaryConditions(
      expandScrollMetrics(position),
      value,
    );
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    return super.createBallisticSimulation(
      expandScrollMetrics(position),
      velocity,
    );
  }
}
