import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brick_breaker/src/widgets/game_hud.dart';

void main() {
  group('GameHud Widget', () {
    testWidgets('displays score and lives correctly', (tester) async {
      final scoreNotifier = ValueNotifier<int>(42);
      final livesNotifier = ValueNotifier<int>(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              score: scoreNotifier,
              lives: livesNotifier,
            ),
          ),
        ),
      );

      // Check score display
      expect(find.text('SCORE: 42'), findsOneWidget);

      // Check lives display
      expect(find.text('LIVES: '), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    });

    testWidgets('updates when score changes', (tester) async {
      final scoreNotifier = ValueNotifier<int>(0);
      final livesNotifier = ValueNotifier<int>(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              score: scoreNotifier,
              lives: livesNotifier,
            ),
          ),
        ),
      );

      expect(find.text('SCORE: 0'), findsOneWidget);

      // Change score
      scoreNotifier.value = 100;
      await tester.pump();

      expect(find.text('SCORE: 100'), findsOneWidget);
      expect(find.text('SCORE: 0'), findsNothing);
    });

    testWidgets('updates when lives change', (tester) async {
      final scoreNotifier = ValueNotifier<int>(0);
      final livesNotifier = ValueNotifier<int>(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              score: scoreNotifier,
              lives: livesNotifier,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNWidgets(3));

      // Lose a life
      livesNotifier.value = 2;
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsNWidgets(2));
    });

    testWidgets('handles zero lives correctly', (tester) async {
      final scoreNotifier = ValueNotifier<int>(0);
      final livesNotifier = ValueNotifier<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameHud(
              score: scoreNotifier,
              lives: livesNotifier,
            ),
          ),
        ),
      );

      expect(find.text('LIVES: '), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });
  });
}