import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'config/power_up_config.dart';
import 'dart:math' as math;
import 'services/high_score_service.dart';
import 'services/audio_service.dart';

enum PlayState { welcome, playing, gameOver, won, paused }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
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
  final ValueNotifier<int> highScore = ValueNotifier(0);
  final HighScoreService _highScoreService = HighScoreService();
  final AudioService _audioService = AudioService();
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;
  
  // Expose audio service for components
  AudioService get audioService => _audioService;
  
  // Power-up tracking
  final Map<PowerUpType, TimerComponent?> _activePowerUps = {};
  double _batSizeMultiplier = 1.0;
  double _ballSpeedMultiplier = 1.0;
  
  // Track held keys for smooth bat movement
  bool _leftPressed = false;
  bool _rightPressed = false;

  PlayState _playState = PlayState.welcome; // Initialize with default value
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        // Remove all balls when level is won
        if (playState == PlayState.won) {
          world.removeAll(world.children.query<Ball>());
        }
        overlays.add(playState.name);
      case PlayState.paused:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        overlays.remove(PlayState.paused.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    // Add animated background first (renders behind everything)
    world.add(AnimatedBackground());
    
    world.add(PlayArea());

    // Load high score
    highScore.value = await _highScoreService.getHighScore();
    
    // Update high score in real-time when current score exceeds it
    score.addListener(_updateHighScore);
    
    // Initialize and start background music
    await _audioService.initialize();
    await _audioService.playBackgroundMusic();

    playState = PlayState.welcome;
  }
  
  void _updateHighScore() {
    if (score.value > highScore.value) {
      highScore.value = score.value;
      // Persist the new high score immediately
      _highScoreService.saveHighScore(score.value);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Don't update game logic while paused
    if (playState == PlayState.paused) {
      return;
    }
    
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

  void pauseGame() {
    if (playState == PlayState.playing) {
      playState = PlayState.paused;
      pauseEngine();
      _audioService.pauseBackgroundMusic();
    }
  }

  void resumeGame() {
    if (playState == PlayState.paused) {
      playState = PlayState.playing;
      resumeEngine();
      _audioService.resumeBackgroundMusic();
    }
  }

  void restartGame() {
    resumeEngine(); // Make sure engine is running
    lives.value = initialLives;
    score.value = 0;
    // Keep current level or reset to 1 as desired
    // level.value = 1;
    playState = PlayState.welcome;
    startGame();
  }

  void quitToMenu() {
    resumeEngine(); // Make sure engine is running
    playState = PlayState.welcome;
  }

  void startGame() {
    
    if (playState == PlayState.playing) {
      return;
    }
    
    // Only reset score and lives when starting a completely new game
    if (playState == PlayState.welcome || playState == PlayState.gameOver) {
      score.value = 0;
      lives.value = initialLives;
      level.value = 1; // Reset to level 1 for new games
     
    } else if (playState == PlayState.won) {
      // Level complete - advance to next level
      if (level.value < maxLevel) {
        level.value++; // Advance to next level
      }
     
    }
    
    // Get level configuration AFTER level is updated
    final currentLevel = level.value;
    final config = levelConfigs[currentLevel] ?? levelConfigs[maxLevel]!;
    
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
    // Don't lose life if level is complete or game is not playing
    if (playState != PlayState.playing) {
      return;
    }
    
    lives.value--;
    
    // Play life lost sound
    _audioService.playLifeLost();
    
    if (lives.value <= 0) {
      // Game over - no more lives
      
      // Play game over sound
      _audioService.playGameOver();
      
      // Save high score
      _saveHighScoreIfNeeded();
      
      // Remove ball and bat
      world.removeAll(world.children.query<Ball>());
      // world.removeAll(world.children.query<Bat>());
      
      playState = PlayState.gameOver;
    } else {
      // Still have lives - restart this level
      
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

  Future<void> _saveHighScoreIfNeeded() async {
    final isNewHigh = await _highScoreService.saveHighScore(score.value);
    if (isNewHigh) {
      highScore.value = score.value;
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

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    startGame();
  }

  @override // Add from here...
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    
    // Debug shortcuts (only on key down)
    if (event is KeyDownEvent) {
      // Press 'P' or ESC to pause/unpause
      if (event.logicalKey == LogicalKeyboardKey.keyP || 
          event.logicalKey == LogicalKeyboardKey.escape) {
        if (playState == PlayState.playing) {
          pauseGame();
        } else if (playState == PlayState.paused) {
          resumeGame();
        }
        return KeyEventResult.handled;
      }
      
      // Press 'W' to win current level
      if (event.logicalKey == LogicalKeyboardKey.keyW) {
        playState = PlayState.won;
        return KeyEventResult.handled;
      }
      // Press 'L' to lose a life
      if (event.logicalKey == LogicalKeyboardKey.keyL) {
        loseLife();
        return KeyEventResult.handled;
      }
      // Press 'G' to trigger game over
      if (event.logicalKey == LogicalKeyboardKey.keyG) {
        lives.value = 0;
        playState = PlayState.gameOver;
        return KeyEventResult.handled;
      }
      // Press 'R' to reset high score (debug only)
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        _highScoreService.clearHighScore();
        highScore.value = 0;
        print('🔄 High score reset to 0');
        return KeyEventResult.handled;
      }
    }
    
    // Don't process movement keys while paused
    if (playState == PlayState.paused) {
      return KeyEventResult.handled;
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

  void activatePowerUp(PowerUpType type) {
    final config = powerUpConfigs[type]!;
    
    // Remove existing timer for this power-up type if it exists
    _activePowerUps[type]?.removeFromParent();
    
    switch (type) {
      case PowerUpType.widerBat:
        _batSizeMultiplier = 1.5;
        _updateBatSize();
        
        if (config.duration > 0) {
          final timer = TimerComponent(
            period: config.duration,
            repeat: false,
            onTick: () {
              _batSizeMultiplier = 1.0;
              _updateBatSize();
              _activePowerUps.remove(type);
            },
          );
          add(timer);
          _activePowerUps[type] = timer;
        }
        
      case PowerUpType.multiBall:
        _spawnExtraBalls();
        
      // case PowerUpType.slowerBall:
      //   _ballSpeedMultiplier = 0.5;
      //   _updateBallSpeeds();
        
      //   if (config.duration > 0) {
      //     final timer = TimerComponent(
      //       period: config.duration,
      //       repeat: false,
      //       onTick: () {
      //         _ballSpeedMultiplier = 1.0;
      //         _updateBallSpeeds();
      //         _activePowerUps.remove(type);
      //       },
      //     );
      //     add(timer);
      //     _activePowerUps[type] = timer;
      //   }
        
      case PowerUpType.extraLife:
        lives.value++;
    }
  }

  void _updateBatSize() {
    final bats = world.children.query<Bat>();
    if (bats.isNotEmpty) {
      final bat = bats.first;
      final config = levelConfigs[level.value] ?? levelConfigs[maxLevel]!;
      bat.size = Vector2(batWidth * config.batSizeFactor * _batSizeMultiplier, batHeight);
    }
  }

  void _updateBallSpeeds() {
    final balls = world.children.query<Ball>();
    for (final ball in balls) {
      ball.velocity.scale(_ballSpeedMultiplier);
    }
  }

  void _spawnExtraBalls() {
    final balls = world.children.query<Ball>().toList();
    if (balls.isEmpty) return;
    
    final originalBall = balls.first;
    final config = levelConfigs[level.value] ?? levelConfigs[maxLevel]!;
    
    // Spawn 2 extra balls
    for (int i = 0; i < 2; i++) {
      final angle = (rand.nextDouble() - 0.5) * 1.5; // Random angle
      world.add(
        Ball(
          difficultyModifier: difficultyModifier,
          radius: ballRadius,
          position: originalBall.position.clone(),
          velocity: Vector2(
            originalBall.velocity.x + math.cos(angle) * 100,
            originalBall.velocity.y + math.sin(angle) * 100,
          ).normalized()..scale((height / 4) * config.ballSpeedFactor * _ballSpeedMultiplier),
          isPowerUpBall: true, // Mark as power-up ball for different color
        ),
      );
    }
  }

  final ValueNotifier<int> coinCount = ValueNotifier(0);

  void addCoin() {
    coinCount.value++;
    score.value += 100; // Award points for collecting a coin
  }
}

@override
Color backgroundColor() => Colors.transparent; // Let animated background show through
