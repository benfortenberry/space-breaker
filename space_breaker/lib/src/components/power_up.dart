import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../space_breaker.dart';
import '../config/power_up_config.dart';
import 'bat.dart';

class PowerUp extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUp({
    required this.powerUpType,
    required super.position,
  }) : super(
          size: Vector2(60, 60), // Increased from 40 to 50
          anchor: Anchor.center,
        );

  final PowerUpType powerUpType;
  final double fallSpeed = 300.0; // Increased from 150 to 300
  bool _collected = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  @override
  void update(double dt) {
    super.update(dt);
    
    // Fall down
    position.y += fallSpeed * dt;
    
    // Remove if off screen
    if (position.y > game.height + size.y) {
      removeFromParent();
    }
  }
  @override
  void render(Canvas canvas) {
    // Don't call super.render() to avoid drawing the rectangle background
    
    final config = powerUpConfigs[powerUpType]!;
    
    // Draw Flutter icon with color
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(config.icon.codePoint),
        style: TextStyle(
          fontSize: 40,
          fontFamily: config.icon.fontFamily,
          package: config.icon.fontPackage,
          color: config.iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size.x - iconPainter.width) / 2,
        (size.y - iconPainter.height) / 2,
      ),
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
      game.activatePowerUp(powerUpType);
      removeFromParent();
    }
  }
}
