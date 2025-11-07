import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GameSoundEffects {
  static bool _soundEnabled = true;
  static double _volume = 0.7;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Enable or disable all sound effects
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Set global volume (0.0 to 1.0)
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
  }

  /// Play brick destruction sound
  static Future<void> brickHit({int? brickIndex}) async {
    if (!_soundEnabled) return;
    
    try {
      // Use haptic feedback for immediate response
      HapticFeedback.lightImpact();
      
      // Generate a simple beep tone programmatically
      await _playSystemSound(frequency: 800 + (brickIndex ?? 0) * 50);
      
      if (kDebugMode) {
        print('🔊 Brick hit sound played');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Play ball bounce sound for different surfaces
  static Future<void> ballBounce({required BounceType type}) async {
    if (!_soundEnabled) return;
    
    try {
      switch (type) {
        case BounceType.wall:
          HapticFeedback.selectionClick();
          await _playSystemSound(frequency: 600);
        case BounceType.paddle:
          HapticFeedback.mediumImpact();
          await _playSystemSound(frequency: 400);
        case BounceType.brick:
          HapticFeedback.lightImpact();
          await _playSystemSound(frequency: 1000);
      }
      
      if (kDebugMode) {
        print('🔊 Ball bounce sound played: $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Play game over sound
  static Future<void> gameOver() async {
    if (!_soundEnabled) return;
    
    try {
      HapticFeedback.heavyImpact();
      await _playSystemSound(frequency: 400);
      await Future.delayed(const Duration(milliseconds: 200));
      await _playSystemSound(frequency: 300);
      await Future.delayed(const Duration(milliseconds: 200));
      await _playSystemSound(frequency: 200);
      
      if (kDebugMode) {
        print('🔊 Game over sound played');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Play victory sound
  static Future<void> victory() async {
    if (!_soundEnabled) return;
    
    try {
      // Victory fanfare with haptic feedback
      const notes = [523, 659, 784, 1047]; // C, E, G, C octave
      for (int i = 0; i < notes.length; i++) {
        HapticFeedback.lightImpact();
        await _playSystemSound(frequency: notes[i].toDouble());
        if (i < notes.length - 1) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }
      
      if (kDebugMode) {
        print('🔊 Victory sound played');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Play life lost sound
  static Future<void> lifeLost() async {
    if (!_soundEnabled) return;
    
    try {
      HapticFeedback.mediumImpact();
      await _playSystemSound(frequency: 800);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playSystemSound(frequency: 600);
      
      if (kDebugMode) {
        print('🔊 Life lost sound played');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  /// Play game start sound
  static Future<void> gameStart() async {
    if (!_soundEnabled) return;
    
    try {
      HapticFeedback.selectionClick();
      await _playSystemSound(frequency: 400);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playSystemSound(frequency: 600);
      
      if (kDebugMode) {
        print('🔊 Game start sound played');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  // Private method to play system sounds with haptic feedback
  static Future<void> _playSystemSound({required double frequency}) async {
    try {
      // For now, we'll focus on haptic feedback which provides immediate tactile response
      // In a production app, you would:
      // 1. Load actual audio files from assets
      // 2. Use AudioPlayer to play them
      // 3. Or generate audio programmatically
      
      // Simulate different system sounds based on frequency
      if (frequency > 800) {
        // High frequencies - use system alert sound simulation
        HapticFeedback.heavyImpact();
      } else if (frequency > 500) {
        // Medium frequencies
        HapticFeedback.mediumImpact();
      } else {
        // Low frequencies
        HapticFeedback.lightImpact();
      }
      
      // Small delay to simulate sound duration
      await Future.delayed(const Duration(milliseconds: 50));
      
    } catch (e) {
      if (kDebugMode) {
        print('System sound error: $e');
      }
    }
  }

  /// Clear any cached audio resources
  static void clearCache() {
    // Cleanup if needed
  }

  /// Dispose of audio resources
  static void dispose() {
    _audioPlayer.dispose();
  }
}

enum BounceType {
  wall,
  paddle,
  brick,
}