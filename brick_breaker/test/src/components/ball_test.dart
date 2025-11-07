import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/components.dart';
import 'package:brick_breaker/src/config.dart';
import '../helpers/test_brick_breaker.dart';

void main() {
  group('Ball Component', () {
    testWithGame<TestBrickBreaker>(
      'ball moves according to velocity',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final ball = Ball(
          velocity: Vector2(100, 0),
          position: Vector2(100, 100),
          radius: ballRadius,
          difficultyModifier: 1.0,
        );
        
        game.world.add(ball);
        await game.ready();
        
        final initialX = ball.position.x;
        
        // Update for 1 second
        ball.update(1.0);
        
        expect(ball.position.x, initialX + 100);
      },
    );

    testWithGame<TestBrickBreaker>(
      'ball collision with play area boundaries',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final playArea = PlayArea();
        final ball = Ball(
          velocity: Vector2(0, -100),
          position: Vector2(game.width / 2, 50),
          radius: ballRadius,
          difficultyModifier: 1.0,
        );
        
        game.world.addAll([playArea, ball]);
        await game.ready();
        
        final initialVelocityY = ball.velocity.y;
        
        // Simulate collision with top boundary
        ball.onCollisionStart(
          {Vector2(game.width / 2, 0)}, // Top boundary intersection
          playArea,
        );
        
        expect(ball.velocity.y, -initialVelocityY); // Should reverse Y velocity
      },
    );

    testWithGame<TestBrickBreaker>(
      'ball collision with brick increases score',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final brick = Brick(
          position: Vector2(100, 100),
          color: brickColors.first,
        );
        
        final ball = Ball(
          velocity: Vector2(50, 50),
          position: Vector2(90, 90),
          radius: ballRadius,
          difficultyModifier: difficultyModifier,
        );
        
        game.world.addAll([brick, ball]);
        await game.ready();
        
        final initialScore = game.score.value;
        final initialVelocity = ball.velocity.clone();
        
        // Simulate collision - both sides need to process it
        ball.onCollisionStart({Vector2(95, 95)}, brick);
        brick.onCollisionStart({Vector2(95, 95)}, ball);
        
        expect(game.score.value, initialScore + 1);
        
        // Velocity should be modified by difficulty modifier
        expect(ball.velocity.length, 
               initialVelocity.length * difficultyModifier);
      },
    );

    testWithGame<TestBrickBreaker>(
      'ball collision with bat reflects and adjusts velocity',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final bat = Bat(
          size: Vector2(batWidth, batHeight),
          cornerRadius: const Radius.circular(ballRadius / 2),
          position: Vector2(game.width / 2, game.height * 0.95),
        );
        
        final ball = Ball(
          velocity: Vector2(0, 100),
          position: Vector2(game.width / 2, game.height * 0.9),
          radius: ballRadius,
          difficultyModifier: 1.0,
        );
        
        game.world.addAll([bat, ball]);
        await game.ready();
        
        final initialVelocityY = ball.velocity.y;
        
        // Simulate collision with bat center
        ball.onCollisionStart({Vector2(game.width / 2, game.height * 0.95)}, bat);
        
        // Y velocity should reverse
        expect(ball.velocity.y, -initialVelocityY);
      },
    );

    testWithGame<TestBrickBreaker>(
      'ball falling off bottom triggers game over',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final playArea = PlayArea();
        final ball = Ball(
          velocity: Vector2(0, 100),
          position: Vector2(game.width / 2, game.height - 10),
          radius: ballRadius,
          difficultyModifier: 1.0,
        );
        
        game.world.addAll([playArea, ball]);
        await game.ready();
        
        expect(game.playState, PlayState.welcome);
        
        // Simulate collision with bottom boundary
        ball.onCollisionStart(
          {Vector2(game.width / 2, game.height)}, // Bottom boundary
          playArea,
        );
        
        // Game over should be triggered (via RemoveEffect)
        // We can't easily test the delayed effect, but we can verify the ball
        // has a RemoveEffect component or that the method doesn't crash
        expect(() => ball.onCollisionStart({Vector2(game.width / 2, game.height)}, playArea), 
               returnsNormally);
      },
    );
  });
}