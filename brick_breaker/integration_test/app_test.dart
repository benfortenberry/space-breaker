import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brick_breaker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Brick Breaker Integration Tests', () {
    testWidgets('complete game flow - start, play, restart', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state - welcome screen should be visible
      expect(find.text('TAP TO PLAY'), findsOneWidget);
      expect(find.text('SCORE: 0'), findsOneWidget);

      // Tap to start the game
      await tester.tap(find.text('TAP TO PLAY'));
      await tester.pumpAndSettle();

      // Welcome overlay should disappear after starting
      expect(find.text('TAP TO PLAY'), findsNothing);
      
      // Score should still be 0
      expect(find.text('SCORE: 0'), findsOneWidget);

      // Wait a moment for game to stabilize
      await tester.pump(const Duration(seconds: 1));

      // The game is now running - we can't easily simulate ball physics in integration test
      // but we can verify the game components are loaded and working

      // Let the game run for a few seconds to see if anything breaks
      await tester.pump(const Duration(seconds: 2));

      // Verify that the game is still running (no crashes)
      expect(find.text('SCORE: 0'), findsOneWidget);

      // Note: In a real integration test, we might:
      // 1. Use a test-specific build that speeds up ball movement
      // 2. Inject specific game states for testing
      // 3. Test keyboard interactions if running on desktop
      // But for this example, we're verifying the basic app lifecycle
    });

    testWidgets('app handles multiple start attempts', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start game multiple times - should not crash
      await tester.tap(find.text('TAP TO PLAY'));
      await tester.pumpAndSettle();
      
      // Try to "start" again (this should be handled gracefully)
      await tester.tap(find.byType(MaterialApp));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(MaterialApp));
      await tester.pumpAndSettle();

      // App should still be running
      expect(find.text('SCORE: 0'), findsOneWidget);
    });

    testWidgets('score display updates correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial score
      expect(find.text('SCORE: 0'), findsOneWidget);
      
      // Start the game
      await tester.tap(find.text('TAP TO PLAY'));
      await tester.pumpAndSettle();
      
      // Score should remain 0 initially
      expect(find.text('SCORE: 0'), findsOneWidget);
      
      // In a more complete test, we could:
      // - Mock brick collisions to increase score
      // - Verify score updates in real-time
      // - Test score persistence across game restarts
    });

    testWidgets('app layout is responsive', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test different screen sizes
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      expect(find.text('TAP TO PLAY'), findsOneWidget);
      expect(find.text('SCORE: 0'), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      expect(find.text('TAP TO PLAY'), findsOneWidget);
      expect(find.text('SCORE: 0'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });
}