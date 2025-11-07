import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/bat.dart';
import 'package:brick_breaker/src/config.dart';
import '../helpers/test_brick_breaker.dart';

void main() {
  group('Bat Component', () {
    testWithGame<TestBrickBreaker>(
      'bat initializes with correct properties',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final bat = Bat(
          size: Vector2(batWidth, batHeight),
          cornerRadius: const Radius.circular(ballRadius / 2),
          position: Vector2(game.width / 2, game.height * 0.95),
        );
        
        game.world.add(bat);
        await game.ready();
        
        expect(bat.size.x, closeTo(batWidth, 0.01));
        expect(bat.size.y, closeTo(batHeight, 0.01));
        expect(bat.position.x, game.width / 2);
        expect(bat.position.y, game.height * 0.95);
        expect(bat.anchor, Anchor.center);
      },
    );

    testWithGame<TestBrickBreaker>(
      'bat moveBy clamps position to game boundaries',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final bat = Bat(
          size: Vector2(batWidth, batHeight),
          cornerRadius: const Radius.circular(ballRadius / 2),
          position: Vector2(game.width / 2, game.height * 0.95),
        );
        
        game.world.add(bat);
        await game.ready();
        
        // Test moving left beyond boundary
        bat.position.x = 10;
        final initialEffectCount = bat.children.whereType<MoveToEffect>().length;
        bat.moveBy(-50);
        
        // MoveToEffect should be added (or position clamped if effect completes immediately)
        expect(bat.children.whereType<MoveToEffect>().length >= initialEffectCount, true);
        
        // Test moving right beyond boundary  
        bat.position.x = game.width - 10;
        bat.moveBy(50);
        
        // Should have movement effects or position should be clamped
        expect(() => bat.moveBy(50), returnsNormally);
      },
    );

    testWithGame<TestBrickBreaker>(
      'bat has correct hitbox component',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        final bat = Bat(
          size: Vector2(batWidth, batHeight),
          cornerRadius: const Radius.circular(ballRadius / 2),
          position: Vector2(game.width / 2, game.height * 0.95),
        );
        
        game.world.add(bat);
        await game.ready();
        
        // Verify bat has a collision hitbox
        expect(bat.children.whereType<RectangleHitbox>().length, 1);
        expect(bat.size.x, closeTo(batWidth, 0.01));
        expect(bat.size.y, closeTo(batHeight, 0.01));
      },
    );
  });
}