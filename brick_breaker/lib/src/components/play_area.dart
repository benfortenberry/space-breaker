import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import '../brick_breaker.dart';

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea()
    : super(
        paint: Paint()..color = Colors.transparent, // Make transparent to show animated background
        children: [RectangleHitbox()],
      );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
