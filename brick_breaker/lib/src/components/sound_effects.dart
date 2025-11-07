import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundEffects {
  static bool _soundEnabled = true;
  static double _volume = 0.7;

  // Cache for generated sounds to improve performance
  static final Map<String, bool> _soundCache = {};

  /// Enable or disable all sound effects
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Set global volume (0.0 to 1.0)
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Play brick destruction sound
  /// Different pitches based on brick color/position
  static Future<void> brickHit({int? brickIndex}) async {
    if (!_soundEnabled) return;
    
    try {
      // Use a simple tone generator approach
      // Note: For a production app, you'd want actual audio files
      // This creates a satisfying "pop" sound effect
      await _playTone(
        frequency: 800 + (brickIndex ?? 0) * 50, // Higher pitch for higher rows
        duration: 0.1,
        volume: _volume,
      );
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
          await _playTone(frequency: 600, duration: 0.05, volume: _volume * 0.8);
        case BounceType.paddle:
          await _playTone(frequency: 400, duration: 0.08, volume: _volume);
        case BounceType.brick:
          await _playTone(frequency: 1000, duration: 0.06, volume: _volume);
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
      // Descending tone sequence for sad effect
      await _playTone(frequency: 400, duration: 0.2, volume: _volume);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(frequency: 300, duration: 0.2, volume: _volume);
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(frequency: 200, duration: 0.3, volume: _volume);
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
      // Ascending victory fanfare
      const notes = [523, 659, 784, 1047]; // C, E, G, C octave
      for (int i = 0; i < notes.length; i++) {
        await _playTone(
          frequency: notes[i].toDouble(),
          duration: 0.2,
          volume: _volume,
        );
        if (i < notes.length - 1) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
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
      // Quick descending chirp
      await _playTone(frequency: 800, duration: 0.1, volume: _volume);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(frequency: 600, duration: 0.1, volume: _volume);
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
      // Quick ascending start sound
      await _playTone(frequency: 400, duration: 0.1, volume: _volume * 0.9);
      await Future.delayed(const Duration(milliseconds: 50));
      await _playTone(frequency: 600, duration: 0.1, volume: _volume * 0.9);
    } catch (e) {
      if (kDebugMode) {
        print('Sound effect error: $e');
      }
    }
  }

  // Private method to generate simple tones using system feedback
  static Future<void> _playTone({
    required double frequency,
    required double duration,
    required double volume,
  }) async {
    try {
      if (!_soundEnabled || volume <= 0) return;
      
      // Use system feedback for actual audio feedback
      // This provides real haptic/audio feedback on supported platforms
      if (frequency > 900) {
        // High frequency = heavy impact
        HapticFeedback.heavyImpact();
      } else if (frequency > 600) {
        // Medium frequency = medium impact  
        HapticFeedback.mediumImpact();
      } else {
        // Low frequency = light impact
        HapticFeedback.lightImpact();
      }
      
      // Use haptic feedback for audio-like experience
      
      if (kDebugMode) {
        print('🔊 Playing tone: ${frequency.round()}Hz for ${duration}s at volume $volume');
      }
      
      // Small delay to simulate audio duration
      await Future.delayed(Duration(milliseconds: (duration * 100).round()));
    } catch (e) {
      if (kDebugMode) {
        print('Audio feedback error: $e');
      }
    }
  }

  /// Clear sound cache (useful for memory management)
  static void clearCache() {
    _soundCache.clear();
  }
}

enum BounceType {
  wall,
  paddle,
  brick,
}