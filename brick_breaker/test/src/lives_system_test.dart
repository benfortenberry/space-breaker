import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';
import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/components.dart';
import 'package:brick_breaker/src/config.dart';
import 'helpers/test_brick_breaker.dart';

void main() {
  group('Lives System', () {
    testWithGame<TestBrickBreaker>(
      'game starts with initial lives',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        expect(game.lives.value, initialLives);
      },
    );

    testWithGame<TestBrickBreaker>(
      'startGame resets lives for new game',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        // Simulate losing some lives
        game.lives.value = 1;
        
        // Start a new game
        game.startGame();
        await game.ready();
        
        expect(game.lives.value, initialLives);
      },
    );

    testWithGame<TestBrickBreaker>(
      'loseLife decreases lives count',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();
        
        final initialLivesCount = game.lives.value;
        
        game.loseLife();
        
        expect(game.lives.value, initialLivesCount - 1);
      },
    );

    testWithGame<TestBrickBreaker>(
      'game over when no lives remaining',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();
        
        // Set lives to 1
        game.lives.value = 1;
        
        // Lose the last life
        game.loseLife();
        
        expect(game.lives.value, 0);
        expect(game.playState, PlayState.gameOver);
      },
    );

    testWithGame<TestBrickBreaker>(
      'respawns ball when lives remaining',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();
        
        // Set lives to 2 so we have one remaining after losing one
        game.lives.value = 2;
        
        expect(game.world.children.query<Ball>().length, 1);
        
        // Lose a life (should respawn)
        game.loseLife();
        
        expect(game.lives.value, 1);
        expect(game.playState, PlayState.playing);
        expect(game.world.children.query<Ball>().length, 1);
      },
    );
  });
}