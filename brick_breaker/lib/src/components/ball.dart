import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import '../brick_breaker.dart';
import 'play_area.dart';
import 'bat.dart';
import 'brick.dart';
import 'particle_effects.dart';
import 'ball_trail_component.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = const Color.fromARGB(255, 255, 255, 255)
           ..style = PaintingStyle.fill,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox());
    add(BallTrailComponent(this));
  }

  final Vector2 velocity;
  final double difficultyModifier;
  
  // Maximum speed to prevent ball from going too fast
  static const double maxSpeed = 1000.0;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    
    // Cap the ball's speed to prevent it from becoming too fast
    final currentSpeed = velocity.length;
    if (currentSpeed > maxSpeed) {
      velocity.normalize();
      velocity.scale(maxSpeed);
    }
  }

  @override // Add from here...
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
        // Wall bounce sound and particles
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
        // Wall bounce sound and particles
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
        // Wall bounce sound and particles
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.y >= game.height) {
        add(
          RemoveEffect(
            delay: 0.35,
            onComplete: () {
              // Call loseLife instead of direct game over
              game.loseLife();
            },
          ),
        );
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x =
          velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
      
      // Paddle bounce sound and particles
      game.world.add(ParticleEffects.ballImpact(
        position: position.clone(),
        color: Colors.orange,
      ));
    } else if (other is Brick) {
      // Brick bounce sound (brick destruction sound is handled in Brick.onCollisionStart)
      
      // Ball-brick collision particles are handled in Brick.onCollisionStart
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
