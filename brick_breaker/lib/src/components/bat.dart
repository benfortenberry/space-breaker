import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class Bat extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]);

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = const Color.fromARGB(255, 255, 255, 255)
    ..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Expand the drag area by making the component's interactive size larger
    // This doesn't affect rendering or collision, just touch/drag detection
    // Make it 3x taller to make it easier to grab
    size = Vector2(size.x, size.y * 3);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Only render the visible bat (1/3 of the component height, centered)
    final visibleHeight = size.y / 3;
    final offsetY = (size.y - visibleHeight) / 2;
    
    canvas.save();
    canvas.translate(0, offsetY);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & Size(size.x, visibleHeight),
        cornerRadius,
      ),
      _paint,
    );
    canvas.restore();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x).clamp(0, game.width);
  }

  void moveBy(double dx) {
    add(
      MoveToEffect(
        Vector2((position.x + dx).clamp(0, game.width), position.y),
        EffectController(duration: 0.1),
      ),
    );
  }
}
