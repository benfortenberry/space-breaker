import 'package:flutter/material.dart';
import '../brick_breaker.dart';
import 'dart:async';

class GameHud extends StatefulWidget {
  const GameHud({
    super.key, 
    required this.score, 
    required this.lives,
    required this.level,
    required this.game,
  });

  final ValueNotifier<int> score;
  final ValueNotifier<int> lives;
  final ValueNotifier<int> level;
  final BrickBreaker game;

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  Timer? _rebuildTimer;
  
  @override
  void initState() {
    super.initState();
    // Rebuild when values change to update pause button visibility
    widget.score.addListener(_onUpdate);
    widget.lives.addListener(_onUpdate);
    widget.level.addListener(_onUpdate);
    
    // Also rebuild periodically to catch play state changes
    _rebuildTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    widget.score.removeListener(_onUpdate);
    widget.lives.removeListener(_onUpdate);
    widget.level.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    // Rebuild to update pause button visibility
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use consistent text style for all HUD elements
    final hudTextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      color: Colors.white,
      fontSize: 16,
    );
    
    return Stack(
      children: [
        // Score, Level, Lives in a row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score and Level display
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: widget.score,
                      builder: (context, score, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Score: $score'.toUpperCase(),
                            style: hudTextStyle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: widget.level,
                      builder: (context, level, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Level: $level'.toUpperCase(),
                            style: hudTextStyle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: widget.game.highScore,
                      builder: (context, highScore, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'High: $highScore'.toUpperCase(),
                            style: hudTextStyle.copyWith(
                              color: Colors.yellow,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 80), // Space for centered pause button
             
              // Lives display
              Flexible(
                child: ValueListenableBuilder<int>(
                  valueListenable: widget.lives,
                  builder: (context, livesCount, child) {
                    // Scale down heart size as lives increase to maintain constant width
                    final heartSize = livesCount <= 3 ? 20.0 : (60.0 / livesCount).clamp(12.0, 20.0);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // Display heart icons for lives
                        SizedBox(
                          width: 100, // Fixed width container
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              livesCount.clamp(0, 10), // Max 10 hearts for display
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: heartSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Pause button - absolutely centered, only visible during gameplay
        if (widget.game.playState == PlayState.playing)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.pause, color: Colors.white),
                iconSize: 28,
                onPressed: () {
                  widget.game.pauseGame();
                },
                tooltip: 'Pause',
              ),
            ),
          ),
        
        // Mute button - top right corner, below life icons
        Positioned(
          top: 50,
          right: 16,
          child: IconButton(
            icon: Icon(
              widget.game.audioService.isMuted 
                ? Icons.volume_off 
                : Icons.volume_up,
              color: Colors.white,
            ),
            iconSize: 24,
            onPressed: () {
              widget.game.audioService.toggleMuteAll();
              // Force rebuild to update icon
              if (mounted) {
                setState(() {});
              }
            },
            tooltip: widget.game.audioService.isMuted ? 'Unmute' : 'Mute',
          ),
        ),
      ],
    );
  }


}