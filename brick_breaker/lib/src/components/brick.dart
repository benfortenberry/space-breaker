import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'particle_effects.dart';

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
    
    
    // Create explosion particles at brick position
    game.world.add(
      ParticleEffects.brickExplosion(
        position: position.clone(),
        brickColor: brickColor,
      ),
    );
    
    // Check if this is the last brick BEFORE removing it
    final bricksCount = game.world.children.query<Brick>().length;
    print('DEBUG BRICK: Bricks count before removing this one: $bricksCount');
    final isLastBrick = bricksCount == 1;
    
    removeFromParent();
    game.score.value++;

    // If this was the last brick, complete the level
    if (isLastBrick) {
      print('DEBUG BRICK: This was the last brick! Completing level ${game.level.value}...');
      
      // Add celebration particles
      game.world.add(
        ParticleEffects.celebration(
          position: Vector2(game.width / 2, game.height / 2),
          gameSize: Vector2(game.width, game.height),
        ),
      );
      
      // Complete the level directly without recounting bricks
      if (game.level.value < maxLevel) {
        print('DEBUG BRICK: Level ${game.level.value} complete, setting playState to won');
        game.playState = PlayState.won;
        print('DEBUG BRICK: playState is now: ${game.playState}');
      } else {
        print('DEBUG BRICK: All levels complete!');
        game.playState = PlayState.gameOver;
      }
      
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
    }
  }
}
