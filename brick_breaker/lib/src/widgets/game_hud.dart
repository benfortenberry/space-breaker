import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key, 
    required this.score, 
    required this.lives,
    required this.level,
  });

  final ValueNotifier<int> score;
  final ValueNotifier<int> lives;
  final ValueNotifier<int> level;

  @override
  Widget build(BuildContext context) {
    // Use consistent text style for all HUD elements
    final hudTextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      color: Colors.white,
      fontSize: 16,
    );
    
    return Padding(
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
                  valueListenable: score,
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
                  valueListenable: level,
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
              ],
            ),
          ),
          
          const SizedBox(width: 16),
         
          // Lives display
          Flexible(
            child: ValueListenableBuilder<int>(
              valueListenable: lives,
              builder: (context, livesCount, child) {
                print('DEBUG HUD: Lives count updated to: $livesCount');
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lives'.toUpperCase(),
                        style: hudTextStyle,
                      ),
                      const SizedBox(height: 8),
                      // Display heart icons for lives on second line
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          livesCount.clamp(0, 5), // Max 5 hearts for display
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}