import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/components.dart';
import 'helpers/test_brick_breaker.dart';

void main() {
  group('BrickBreaker', () {

    testWithGame<TestBrickBreaker>(
      'initial game setup',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        expect(game.playState, PlayState.welcome);
        expect(game.score.value, 0);
        expect(game.world.children.query<PlayArea>().length, 1);
        expect(game.world.children.query<Ball>().length, 0);
        expect(game.world.children.query<Bat>().length, 0);
        expect(game.world.children.query<Brick>().length, 0);
      },
    );

    testWithGame<TestBrickBreaker>(
      'startGame creates game components and sets playing state',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        game.startGame();
        await game.ready();
        
        expect(game.playState, PlayState.playing);
        expect(game.score.value, 0);
        expect(game.world.children.query<Ball>().length, 1);
        expect(game.world.children.query<Bat>().length, 1);
        expect(game.world.children.query<Brick>().length, 50); // 10 colors × 5 rows
      },
    );

    testWithGame<TestBrickBreaker>(
      'startGame called twice does not duplicate components',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        game.startGame();
        await game.ready();
        
        // Call startGame again
        game.startGame();
        await game.ready();
        
        expect(game.playState, PlayState.playing);
        expect(game.world.children.query<Ball>().length, 1);
        expect(game.world.children.query<Bat>().length, 1);
        expect(game.world.children.query<Brick>().length, 50);
      },
    );

    testWithGame<TestBrickBreaker>(
      'restart after game over resets score and removes duplicates',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        // Start game
        game.startGame();
        await game.ready();
        
        // Simulate scoring points
        game.score.value = 25;
        
        // Simulate game over
        game.playState = PlayState.gameOver;
        
        // Restart game
        game.startGame();
        await game.ready();
        
        expect(game.playState, PlayState.playing);
        expect(game.score.value, 0);
        expect(game.world.children.query<Ball>().length, 1);
        expect(game.world.children.query<Bat>().length, 1);
        expect(game.world.children.query<Brick>().length, 50);
      },
    );

    testWithGame<TestBrickBreaker>(
      'play state changes work correctly in test environment',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        // Test game doesn't manage overlays, just test state changes
        expect(game.playState, PlayState.welcome);
        
        // Playing state
        game.playState = PlayState.playing;
        expect(game.playState, PlayState.playing);
        
        // Game over state
        game.playState = PlayState.gameOver;
        expect(game.playState, PlayState.gameOver);
        
        // Won state
        game.playState = PlayState.won;
        expect(game.playState, PlayState.won);
      },
    );

    testWithGame<TestBrickBreaker>(
      'keyboard input methods work without errors',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();
        
        // Create a mock key event - we're mainly testing that methods don't crash
        final mockEvent = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.space,
          logicalKey: LogicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        
        // Test that keyboard handling doesn't throw exceptions
        expect(() => game.onKeyEvent(mockEvent, {LogicalKeyboardKey.space}), 
               returnsNormally);
        
        // Test that bat exists and game is in playing state
        expect(game.world.children.query<Bat>().isNotEmpty, true);
        expect(game.playState, PlayState.playing);
      },
    );

    testWithGame<TestBrickBreaker>(
      'tap handling starts game',
      TestBrickBreaker.new,
      (game) async {
        await game.ready();
        
        expect(game.playState, PlayState.welcome);
        
        game.onTap();
        await game.ready();
        
        expect(game.playState, PlayState.playing);
        expect(game.world.children.query<Ball>().length, 1);
        expect(game.world.children.query<Bat>().length, 1);
        expect(game.world.children.query<Brick>().length, 50);
      },
    );

    group('Score Management', () {
      testWithGame<TestBrickBreaker>(
        'score starts at zero',
        TestBrickBreaker.new,
        (game) async {
          await game.ready();
          expect(game.score.value, 0);
        },
      );

      testWithGame<TestBrickBreaker>(
        'score resets on game start',
        TestBrickBreaker.new,
        (game) async {
          await game.ready();
          
          // Manually set score
          game.score.value = 100;
          expect(game.score.value, 100);
          
          // Start game should reset score
          game.startGame();
          await game.ready();
          
          expect(game.score.value, 0);
        },
      );
    });

    group('Component Management', () {
      testWithGame<TestBrickBreaker>(
        'removes only dynamic components on restart',
        TestBrickBreaker.new,
        (game) async {
          await game.ready();
          
          // Verify PlayArea exists initially
          expect(game.world.children.query<PlayArea>().length, 1);
          
          game.startGame();
          await game.ready();
          
          // Verify all components exist
          expect(game.world.children.query<PlayArea>().length, 1);
          expect(game.world.children.query<Ball>().length, 1);
          expect(game.world.children.query<Bat>().length, 1);
          expect(game.world.children.query<Brick>().length, 50);
          
          // Restart should keep PlayArea but remove dynamic components
          game.startGame();
          await game.ready();
          
          expect(game.world.children.query<PlayArea>().length, 1);
          expect(game.world.children.query<Ball>().length, 1);
          expect(game.world.children.query<Bat>().length, 1);
          expect(game.world.children.query<Brick>().length, 50);
        },
      );
    });
  });
}