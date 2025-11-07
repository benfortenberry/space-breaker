import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'dart:math' as math;

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> lives = ValueNotifier(initialLives);
  final ValueNotifier<int> level = ValueNotifier(1);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  
  // Track held keys for smooth bat movement
  bool _leftPressed = false;
  bool _rightPressed = false;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    // Add animated background first (renders behind everything)
    world.add(AnimatedBackground());
    
    world.add(PlayArea());

    playState = PlayState.welcome;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move bat continuously while keys are held
    if (playState == PlayState.playing) {
      final bats = world.children.query<Bat>();
      if (bats.isNotEmpty) {
        final bat = bats.first;
        if (_leftPressed) {
          bat.moveBy(-batStep);
        }
        if (_rightPressed) {
          bat.moveBy(batStep);
        }
      }
    }
  }

  void startGame() {
    print('DEBUG: startGame() called with playState: $playState, level: ${level.value}');
    
    if (playState == PlayState.playing) {
      print('DEBUG: Already playing, returning');
      return;
    }
    
    // Only reset score and lives when starting a completely new game
    if (playState == PlayState.welcome || playState == PlayState.gameOver) {
      print('DEBUG: New game - resetting score and lives');
      score.value = 0;
      lives.value = initialLives;
      level.value = 1; // Reset to level 1 for new games
     
    } else if (playState == PlayState.won) {
      // Level complete - advance to next level
      print('DEBUG: Level won - current level: ${level.value}');
      if (level.value < maxLevel) {
        level.value++; // Advance to next level
        print('DEBUG: Advanced to level: ${level.value}');
      }
     
    }
    
    // Get level configuration AFTER level is updated
    final currentLevel = level.value;
    final config = levelConfigs[currentLevel] ?? levelConfigs[maxLevel]!;
    print('DEBUG: Starting level $currentLevel with config: ${config.rows} rows, speed factor: ${config.ballSpeedFactor}');
    
    playState = PlayState.playing;
    // remove any existing dynamic game components so we
    // don't duplicate them when restarting the game

    // remove previous balls, bats and bricks (keep PlayArea)
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    world.add(
      Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2(
          (rand.nextDouble() - 0.5) * width,
          height * 0.2,
        ).normalized()..scale((height / 4) * config.ballSpeedFactor),
      ),
    );

    world.add(
      // Add from here...
      Bat(
        size: Vector2(batWidth * config.batSizeFactor, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95),
      ),
    );

    // Calculate colors and brick width for this level
    final colorsToUse = config.endColor - config.startColor + 1;
    final brickWidthForLevel = 
        (gameWidth - (brickGutter * (colorsToUse + 1))) / colorsToUse;
    
    world.addAll([
      // Add bricks based on level configuration
      for (var row = 1; row <= config.rows; row++)
        for (var col = 0; col < colorsToUse; col++)
          Brick(
            position: Vector2(
              (col + 0.5) * brickWidthForLevel + (col + 1) * brickGutter,
              (row + 2.0) * brickHeight + row * brickGutter,
            ),
            color: brickColors[(config.startColor + col) % brickColors.length],
          ),
    ]);


    
  }

  void loseLife() {
    print('DEBUG: loseLife() called - current lives: ${lives.value}');
    lives.value--;
    print('DEBUG: Lives after decrement: ${lives.value}');
    print('DEBUG: Checking game over condition: lives.value <= 0 is ${lives.value <= 0}');
    
    if (lives.value <= 0) {
      // Game over - no more lives
      print('DEBUG: GAME OVER - Setting playState to gameOver');
      
      // Remove ball and bat
      world.removeAll(world.children.query<Ball>());
      // world.removeAll(world.children.query<Bat>());
      
      playState = PlayState.gameOver;
      print('DEBUG: playState is now: $playState');
    } else {
      // Still have lives - restart this level
      print('DEBUG: Still have ${lives.value} lives - restarting level ${level.value}');
      
      // Remove ball and bat only (keep bricks and score)
      world.removeAll(world.children.query<Ball>());
      // world.removeAll(world.children.query<Bat>());
      
      // Re-add ball and bat without changing playState or resetting lives
      final config = levelConfigs[level.value] ?? levelConfigs[maxLevel]!;
      
      world.add(
        Ball(
          difficultyModifier: difficultyModifier,
          radius: ballRadius,
          position: size / 2,
          velocity: Vector2(
            (rand.nextDouble() - 0.5) * width,
            height * 0.2,
          ).normalized()..scale((height / 4) * config.ballSpeedFactor),
        ),
      );

      // world.add(
      //   Bat(
      //     size: Vector2(batWidth * config.batSizeFactor, batHeight),
      //     cornerRadius: const Radius.circular(ballRadius / 2),
      //     position: Vector2(width / 2, height * 0.95),
      //   ),
      // );
    }
  }

  void checkLevelComplete() {
    final remainingBricks = world.children.query<Brick>().length;
    print('DEBUG: checkLevelComplete - remaining bricks: $remainingBricks, current level: ${level.value}');
    if (remainingBricks == 0) {
      // Level complete!
      if (level.value < maxLevel) {
        print('DEBUG: Level ${level.value} complete, setting playState to won');
        playState = PlayState.won; // This will show the level complete overlay
        print('DEBUG: playState is now: $playState');
      } else {
        // Game completed - all levels finished!
        print('DEBUG: All levels complete!');
        playState = PlayState.gameOver;
      }
    }
  }
  
  void respawnBall() {
    // Remove existing balls
    world.removeAll(world.children.query<Ball>());
    
    // Add new ball
    world.add(
      Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2(
          (rand.nextDouble() - 0.5) * width,
          height * 0.2,
        ).normalized()..scale(height / 4),
      ),
    );
  }

  @override // Add from here...
  void onTap() {
    super.onTap();
    print('DEBUG: onTap called, current playState: $playState, current level: ${level.value}');
    startGame();
    print('DEBUG: After startGame, level is now: ${level.value}, playState: $playState');
  }

  @override // Add from here...
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    
    // Debug shortcuts (only on key down)
    if (event is KeyDownEvent) {
      // Press 'W' to win current level
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        print('DEBUG: Manual win triggered');
        playState = PlayState.won;
        return KeyEventResult.handled;
      }
      // Press 'L' to lose a life
      if (event.logicalKey == LogicalKeyboardKey.keyL) {
        print('DEBUG: Manual life loss triggered');
        loseLife();
        return KeyEventResult.handled;
      }
      // Press 'G' to trigger game over
      if (event.logicalKey == LogicalKeyboardKey.keyG) {
        print('DEBUG: Manual game over triggered');
        lives.value = 0;
        playState = PlayState.gameOver;
        return KeyEventResult.handled;
      }
    }
    
    // Track arrow key press/release for continuous movement
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _leftPressed = true;
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _rightPressed = true;
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _leftPressed = false;
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _rightPressed = false;
        return KeyEventResult.handled;
      }
    }
    
    // Other controls
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.enter:
          startGame();
          return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.handled;
  }
}

@override
Color backgroundColor() => Colors.transparent; // Let animated background show through
