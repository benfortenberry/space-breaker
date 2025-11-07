import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key, 
    required this.score, 
    required this.lives,
  });

  final ValueNotifier<int> score;
  final ValueNotifier<int> lives;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score display
          ValueListenableBuilder<int>(
            valueListenable: score,
            builder: (context, score, child) {
              return Text(
                'Score: $score'.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge!,
              );
            },
          ),
          // Lives display
          ValueListenableBuilder<int>(
            valueListenable: lives,
            builder: (context, livesCount, child) {
              return Row(
                children: [
                  Text(
                    'Lives: '.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge!,
                  ),
                  // Display heart icons for lives
                  Row(
                    children: List.generate(
                      livesCount.clamp(0, 5), // Max 5 hearts for display
                      (index) => const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}