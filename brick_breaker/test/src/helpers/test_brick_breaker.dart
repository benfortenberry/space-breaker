import 'dart:async';
import 'package:flame/components.dart';
import 'package:brick_breaker/src/brick_breaker.dart';
import 'package:brick_breaker/src/components/components.dart';

/// Test-specific BrickBreaker game that doesn't require overlay management
/// This allows us to test game logic without needing Flutter widget overlays
class TestBrickBreaker extends BrickBreaker {
  @override
  set playState(PlayState playState) {
    _playState = playState;
    // Skip overlay management in tests - just store the state
    // The actual overlay management is tested separately in widget tests
  }

  PlayState _playState = PlayState.welcome;
  
  @override
  PlayState get playState => _playState;

  @override
  FutureOr<void> onLoad() async {
    // Skip the super.onLoad() that sets up overlays and just set up the game world
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    _playState = PlayState.welcome;
  }
}