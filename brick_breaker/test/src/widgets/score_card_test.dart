import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brick_breaker/src/widgets/score_card.dart';

void main() {
  group('ScoreCard Widget', () {
    testWidgets('displays initial score of 0', (WidgetTester tester) async {
      final scoreNotifier = ValueNotifier<int>(0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreCard(score: scoreNotifier),
          ),
        ),
      );
      
      expect(find.text('SCORE: 0'), findsOneWidget);
    });

    testWidgets('updates when score changes', (WidgetTester tester) async {
      final scoreNotifier = ValueNotifier<int>(0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreCard(score: scoreNotifier),
          ),
        ),
      );
      
      expect(find.text('SCORE: 0'), findsOneWidget);
      
      // Update the score
      scoreNotifier.value = 150;
      await tester.pump();
      
      expect(find.text('SCORE: 150'), findsOneWidget);
      expect(find.text('SCORE: 0'), findsNothing);
    });

    testWidgets('displays large numbers correctly', (WidgetTester tester) async {
      final scoreNotifier = ValueNotifier<int>(999999);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreCard(score: scoreNotifier),
          ),
        ),
      );
      
      expect(find.text('SCORE: 999999'), findsOneWidget);
    });

    testWidgets('score text is uppercase', (WidgetTester tester) async {
      final scoreNotifier = ValueNotifier<int>(42);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreCard(score: scoreNotifier),
          ),
        ),
      );
      
      // Verify the text is uppercase (should find "SCORE:" not "score:")
      expect(find.text('SCORE: 42'), findsOneWidget);
      expect(find.text('score: 42'), findsNothing);
    });

    testWidgets('has proper text styling', (WidgetTester tester) async {
      final scoreNotifier = ValueNotifier<int>(100);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreCard(score: scoreNotifier),
          ),
        ),
      );
      
      final textWidget = tester.widget<Text>(find.text('SCORE: 100'));
      // Test that the text widget exists and has a color (don't test specific color)
      expect(textWidget.style, isNotNull);
      expect(textWidget.style?.color, isNotNull);
    });
  });
}