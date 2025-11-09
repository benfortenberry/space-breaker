import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _webAudioUnlocked = false;

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _allMuted = false; // Master mute
  double _musicVolume = 0.07; // Reduced from 0.5 to 0.2
  double _sfxVolume = 0.7;
  
  // Background music tracks
  final List<String> _backgroundTracks = [
    'audio/background/a.wav',
    'audio/background/d.wav',
    'audio/background/s.wav',
     'audio/background/g.wav',
      'audio/background/f.wav',
       'audio/background/h.wav',
        'audio/background/k.wav',
         'audio/background/j.wav',
  ];
  
  final math.Random _random = math.Random();
  
  // Track active music players
  final List<AudioPlayer> _activeMusicPlayers = [];
  Timer? _nextTrackTimer;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  bool get isMuted => _allMuted;

  Future<void> initialize() async {
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    
    // Web-specific audio unlock
    if (kIsWeb && !_webAudioUnlocked) {
      await _unlockWebAudio();
    }
    
    print(
      'AudioService initialized - Music enabled: $_musicEnabled, SFX enabled: $_sfxEnabled, Music volume: $_musicVolume, Web: $kIsWeb',
    );
  }
  
  Future<void> _unlockWebAudio() async {
    try {
      // Create a silent audio to unlock audio context on web
      final player = AudioPlayer();
      await player.setVolume(0);
      await player.play(AssetSource('audio/boop.wav')); // Use existing audio file
      await player.stop();
      await player.dispose();
      _webAudioUnlocked = true;
      print('Web audio unlocked successfully');
      
      // Start background music now that audio is unlocked
      if (_musicEnabled && !_allMuted && _activeMusicPlayers.isEmpty) {
        await _playNextRandomTrack();
      }
    } catch (e) {
      print('Failed to unlock web audio: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled || _allMuted) {
      print('Music disabled or muted, not playing background music');
      return;
    }
    
    // On web, don't start background music until user interaction
    if (kIsWeb && !_webAudioUnlocked) {
      print('Web audio not yet unlocked, waiting for user interaction');
      return;
    }
    
    print('Starting background music...');
    await _playNextRandomTrack();
  }
  
  Future<void> _playNextRandomTrack() async {
    if (!_musicEnabled || _allMuted) return;
    try {
      // Pick a random track
      final track = _backgroundTracks[_random.nextInt(_backgroundTracks.length)];
      print('Attempting to play background track: $track');
      
      // Create a new player for this track
      final player = AudioPlayer();
      await player.setVolume(_musicVolume);
      await player.setReleaseMode(ReleaseMode.release);
      
      // Start playing the track
      await player.play(AssetSource(track));
      _activeMusicPlayers.add(player);
      print('Successfully started playing: $track');
      
      // Clean up player when done
      player.onPlayerComplete.listen((_) {
        _activeMusicPlayers.remove(player);
        player.dispose();
      });
      
      // Get the duration of the track to schedule the next one
      player.getDuration().then((duration) {
        if (duration != null && _musicEnabled) {
          // Start next track 2 seconds before this one ends for overlap
          final overlapTime = duration - const Duration(seconds: 10);
          if (overlapTime.inMilliseconds > 0) {
            _nextTrackTimer?.cancel();
            _nextTrackTimer = Timer(overlapTime, () {
              _playNextRandomTrack();
            });
          } else {
            // Track is too short, just play next one immediately when this completes
            player.onPlayerComplete.listen((_) {
              _playNextRandomTrack();
            });
          }
        }
      });
      
    } catch (e, stackTrace) {
      print('Error playing background music: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> stopBackgroundMusic() async {
    _nextTrackTimer?.cancel();
    for (final player in _activeMusicPlayers) {
      await player.stop();
      await player.dispose();
    }
    _activeMusicPlayers.clear();
  }

  Future<void> pauseBackgroundMusic() async {
    _nextTrackTimer?.cancel();
    for (final player in _activeMusicPlayers) {
      await player.pause();
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    for (final player in _activeMusicPlayers) {
      await player.resume();
    }
    // If no players are active, start a new track
    if (_activeMusicPlayers.isEmpty) {
      await _playNextRandomTrack();
    }
  }

  Future<void> playSoundEffect(String soundName) async {
    if (!_sfxEnabled || _allMuted) {
      print('SFX disabled or muted, not playing $soundName');
      return;
    }
    
    // Web audio unlock on first user interaction
    if (kIsWeb && !_webAudioUnlocked) {
      await _unlockWebAudio();
    }
    
    try {
      print('Playing sound: $soundName at volume $_sfxVolume');
      print('Audio file path: audio/$soundName');

      // Create a new AudioPlayer instance for each sound
      // This allows multiple sounds to play simultaneously
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.setReleaseMode(ReleaseMode.release);

      // Play the sound
      await player.play(AssetSource('audio/$soundName'));
      print('Sound play command sent for: $soundName');

      // Dispose the player after the sound completes
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      print('Error playing sound $soundName: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> playLifeLost() async {
    await playSoundEffect('hit4.wav');
  }

  Future<void> playBoop() async {
    await playSoundEffect('boop.wav');
  }

  Future<void> playBrickBlast() async {
    await playSoundEffect('brick_blast.wav');
  }


  Future<void> playLevelClear() async {
    await playSoundEffect('level_up.wav');
  }
  
  Future<void> playBump() async {
    await playSoundEffect('bump.wav');
  }
  
  Future<void> playGameOver() async {
    await playSoundEffect('gameover.wav');
  }
  
  Future<void> playPowerUp() async {
    print('Playing power-up sound');
    await playSoundEffect('power_up3.wav');
  }
  
  Future<void> playGameWon() async {
    await playSoundEffect('game_won.wav');
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }
  
  void toggleMuteAll() {
    _allMuted = !_allMuted;
    if (_allMuted) {
      // Mute all active music
      for (final player in _activeMusicPlayers) {
        player.setVolume(0.0);
      }
    } else {
      // Unmute all active music
      for (final player in _activeMusicPlayers) {
        player.setVolume(_musicVolume);
      }
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    // Update volume for all active music players
    for (final player in _activeMusicPlayers) {
      player.setVolume(_musicVolume);
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  Future<void> dispose() async {
    _nextTrackTimer?.cancel();
    for (final player in _activeMusicPlayers) {
      await player.dispose();
    }
    _activeMusicPlayers.clear();
    await _sfxPlayer.dispose();
  }
}
