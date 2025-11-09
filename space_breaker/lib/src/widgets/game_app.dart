import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../space_breaker.dart';
import '../config.dart';
import 'overlay_screen.dart'; // Add this import
import 'game_hud.dart';
import 'animated_gradient_background.dart';
import 'pause_menu.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override // Add from here...
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color.fromARGB(255, 255, 255, 255),
          displayColor: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home: Scaffold(
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  // Modify from here...
                  children: [
                    GameHud(
                      score: game.score, 
                      lives: game.lives, 
                      level: game.level,
                      game: game,
                    ),
                    Expanded(
                      child: FittedBox(
                        child: SizedBox(
                          width: gameWidth,
                          height: gameHeight,
                          child: GameWidget(
                            game: game,
                            overlayBuilderMap: {
                              PlayState.welcome.name: (context, game) =>
                                  const OverlayScreen(
                                    title: 'TAP TO PLAY',
                                    subtitle: 'Use arrow keys or swipe',
                                  ),
                              PlayState.paused.name: (context, game) =>
                                  PauseMenu(game: this.game),
                              PlayState.gameOver.name: (context, game) =>
                                  const OverlayScreen(
                                    title: 'G A M E   O V E R',
                                    subtitle: 'Tap to Play Again',
                                  ),
                              PlayState.won.name: (context, game) =>
                                  ValueListenableBuilder<int>(
                                    valueListenable: this.game.level,
                                    builder: (context, level, child) {
                                      if (level >= maxLevel) {
                                        return const OverlayScreen(
                                          title: 'GAME COMPLETE!',
                                          subtitle: 'You beat all levels! Tap to play again',
                                        );
                                      } else {
                                        return OverlayScreen(
                                          title: 'LEVEL $level COMPLETE!',
                                          subtitle: 'Tap to continue to Level ${level + 1}',
                                        );
                                      }
                                    },
                                  ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ), // To here.
              ),
            ),
          ),
        ),
      ),
    );
  }
}
