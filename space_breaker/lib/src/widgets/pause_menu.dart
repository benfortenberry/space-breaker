import 'package:flutter/material.dart';
import '../space_breaker.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.game,
  });

  final BrickBreaker game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(48.0), // Increased from 32 to 48
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PAUSED',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith( // Changed from displaySmall to displayMedium
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 48), // Increased from 40 to 48
                _MenuButton(
                  text: 'RESUME',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    game.resumeGame();
                  },
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  text: 'RESTART',
                  icon: Icons.refresh,
                  onPressed: () {
                    game.restartGame();
                  },
                ),
                // const SizedBox(height: 16),
                // _MenuButton(
                //   text: 'QUIT',
                //   icon: Icons.exit_to_app,
                //   onPressed: () {
                //     game.quitToMenu();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280, // Increased from 200 to 280
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24), // Added explicit icon size
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0f3460),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32), // Increased padding
          textStyle: Theme.of(context).textTheme.titleLarge, // Changed from titleMedium to titleLarge
        ),
      ),
    );
  }
}
