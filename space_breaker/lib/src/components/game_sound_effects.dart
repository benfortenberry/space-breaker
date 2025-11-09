import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum BounceType { wall, paddle, brick }

class GameSoundEffects {
  static bool _soundEnabled = true;
  static double _volume = 0.7;

  /// Enable or disable all sound effects
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (kDebugMode) {
      print('🔊 Sound ${enabled ? 'ENABLED' : 'DISABLED'}');
    }
  }

  /// Set global volume (0.0 to 1.0)
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    if (kDebugMode) {
      print('🔊 Volume set to $_volume');
    }
  }

  /// Play brick destruction sound
  static Future<void> brickHit() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Play ball bounce sound based on what it bounced off
  static Future<void> ballBounce({required BounceType type}) async {
    if (!_soundEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Play game start sound
  static Future<void> gameStart() async {
    if (!_soundEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Play life lost sound
  static Future<void> lifeLost() async {
    if (!_soundEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Play game over sound
  static Future<void> gameOver() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Play victory sound
  static Future<void> victory() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Play test sound
  static Future<void> testSound() async {
    if (kDebugMode) {
      print('🔊 TEST SOUND CALLED - soundEnabled: $_soundEnabled, volume: $_volume');
    }
    if (!_soundEnabled) return;
    HapticFeedback.mediumImpact();
    if (kDebugMode) {
      print('🔊 Test haptic feedback triggered');
    }
  }

  /// Clear any cached resources
  static Future<void> clearCache() async {
    // Nothing to clear
  }

  /// Get current sound enabled state
  static bool get isSoundEnabled => _soundEnabled;

  /// Get current volume
  static double get volume => _volume;
}
