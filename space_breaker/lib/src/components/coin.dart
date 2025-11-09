import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../space_breaker.dart';
import 'bat.dart';

class Coin extends RectangleComponent with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Coin({required super.position})
      : super(
          size: Vector2(40, 40),
          anchor: Anchor.center,
        );

  final double fallSpeed = 220.0;
  bool _collected = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;
    if (position.y > game.height + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw gold circle
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
    // Draw coin emoji
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🪙',
        style: TextStyle(fontSize: 28),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bat && !_collected) {
      _collected = true;
      // Add to score or coins (implement in BrickBreaker)
      game.addCoin();
      removeFromParent();
    }
  }
}
