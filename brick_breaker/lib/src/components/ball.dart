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
    this.isPowerUpBall = false,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = isPowerUpBall 
               ? const Color.fromARGB(255, 255, 100, 255) // Purple/magenta for power-up balls
               : const Color.fromARGB(255, 255, 255, 255) // White for main ball
           ..style = PaintingStyle.fill,
       );

  final bool isPowerUpBall;

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
  
  // Sound cooldown to prevent rapid-fire bump sounds
  double _bumpSoundCooldown = 0.0;
  static const double _bumpSoundCooldownTime = 0.1; // 100ms between bump sounds

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    
    // Update sound cooldown
    if (_bumpSoundCooldown > 0) {
      _bumpSoundCooldown -= dt;
    }
    
    // Cap the ball's speed to prevent it from becoming too fast
    final currentSpeed = velocity.length;
    if (currentSpeed > maxSpeed) {
      velocity.normalize();
      velocity.scale(maxSpeed);
    }
    
    // Hard clamp to prevent ball from escaping through walls (tunneling)
    // This catches cases where the ball moves too fast for collision detection
    if (position.y < radius) {
      position.y = radius;
      velocity.y = velocity.y.abs(); // Bounce down
      if (_bumpSoundCooldown <= 0) {
        game.audioService.playBump();
        _bumpSoundCooldown = 0.1;
      }
    }
    if (position.x < radius) {
      position.x = radius;
      velocity.x = velocity.x.abs(); // Bounce right
      if (_bumpSoundCooldown <= 0) {
        game.audioService.playBump();
        _bumpSoundCooldown = 0.1;
      }
    }
    if (position.x > game.width - radius) {
      position.x = game.width - radius;
      velocity.x = -velocity.x.abs(); // Bounce left
      if (_bumpSoundCooldown <= 0) {
        game.audioService.playBump();
        _bumpSoundCooldown = 0.1;
      }
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
        // game.audioService.playBump();
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
        // Wall bounce sound and particles
        // game.audioService.playBump();
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
        // Wall bounce sound and particles
        // game.audioService.playBump();
        game.world.add(ParticleEffects.ballImpact(
          position: position.clone(),
          color: Colors.lightBlue,
        ));
      } else if (intersectionPoints.first.y >= game.height) {
        add(
          RemoveEffect(
            delay: 0.35,
            onComplete: () {
              // Only main ball causes life loss
              if (!isPowerUpBall) {
                game.loseLife();
              }
            },
          ),
        );
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x =
          velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
      
    game.audioService.playBoop();

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
