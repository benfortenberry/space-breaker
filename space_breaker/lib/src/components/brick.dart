import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../space_breaker.dart';
import '../config.dart';
import '../config/power_up_config.dart';
import 'particle_effects.dart';
import 'power_up.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  final Color brickColor;
  
  Brick({required super.position, required Color color})
    : brickColor = color,
      super(
        size: Vector2(brickWidth, brickHeight),
        anchor: Anchor.center,
        paint: Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        children: [RectangleHitbox()],
      );

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Add score for destroying brick
    game.score.value += 1;
    
    // Play brick blast sound
    game.audioService.playBrickBlast();
    
    // Create explosion particles at brick position
    game.world.add(
      ParticleEffects.brickExplosion(
        position: position.clone(),
        brickColor: brickColor,
      ),
    );
    
    // Randomly drop power-up (20% chance)
    final random = math.Random();
    if (random.nextDouble() < 0.20) {
      final powerUpTypes = PowerUpType.values;
      final randomPowerUp = powerUpTypes[random.nextInt(powerUpTypes.length)];
      
      game.world.add(
        PowerUp(
          powerUpType: randomPowerUp,
          position: position.clone(),
        ),
      );
    }
    
    // Check if this is the last brick BEFORE removing it
    final bricksCount = game.world.children.query<Brick>().length;
    removeFromParent();
    if (bricksCount == 1) {
      // Check if this is the final level
      if (game.level.value >= 10) {
        game.audioService.playGameWon(); // Play game won sound for final level
      } else {
        game.audioService.playLevelClear(); // Play level up sound
      }
      game.playState = PlayState.won;
    }
  }
}
