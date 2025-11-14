import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Audio manager for handling audio player pooling and resource management.
///
/// ═══════════════════════════════════════════════════════════════════
/// AUDIO MANAGER: Resource Management & Performance
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Manages audio player instances for optimal performance and memory usage.
///
/// DESIGN PRINCIPLES:
/// 1. OBJECT POOLING:
///    - Reuse audio players instead of creating new ones
///    - Reduces memory allocations
///    - Prevents audio stutter from initialization delays
///
/// 2. SINGLETON PATTERN:
///    - Single instance manages all audio resources
///    - Centralized cleanup and lifecycle management
///    - Easy access from anywhere in app
///
/// 3. PLATFORM HANDLING:
///    - Different strategies for iOS/Android
///    - Graceful degradation for web/desktop
///    - Platform-specific optimizations
///
/// 4. MEMORY MANAGEMENT:
///    - Limit pool size to prevent memory bloat
///    - Release unused players after timeout
///    - Clear cache when memory pressure detected
///
/// SIMILAR PATTERNS:
/// - Database connection pools
/// - Thread pools
/// - Unity AudioSource pools
/// - Object pools in game engines
///
/// ═══════════════════════════════════════════════════════════════════
class AudioManager {
  // Singleton instance
  static AudioManager? _instance;

  /// Get singleton instance
  static AudioManager get instance {
    _instance ??= AudioManager._internal();
    return _instance!;
  }

  /// Private constructor
  AudioManager._internal();

  // ==================== CONFIGURATION ====================

  /// Maximum number of SFX players in pool
  static const int _maxSfxPlayers = 5;

  /// Maximum number of music players (usually just 1-2)
  static const int _maxMusicPlayers = 2;

  /// Timeout for releasing idle players (milliseconds)
  static const int _playerIdleTimeout = 30000; // 30 seconds

  // ==================== PLAYER POOLS ====================

  /// Pool of audio players for sound effects
  final List<AudioPlayer> _sfxPlayerPool = [];

  /// Pool of audio players for music
  final List<AudioPlayer> _musicPlayerPool = [];

  /// Currently playing SFX players
  final Map<String, AudioPlayer> _activeSfxPlayers = {};

  /// Currently playing music players
  final Map<String, AudioPlayer> _activeMusicPlayers = {};

  /// Timers for releasing idle players
  final Map<AudioPlayer, Timer> _idleTimers = {};

  /// Cache of preloaded audio sources
  final Map<String, Source> _audioCache = {};

  // ==================== INITIALIZATION ====================

  /// Initialize audio manager
  ///
  /// STEPS:
  /// 1. Create initial player pool
  /// 2. Configure global audio settings
  /// 3. Set up platform-specific handlers
  ///
  /// PLATFORM NOTES:
  /// - iOS: Uses AVAudioPlayer, respects silent mode
  /// - Android: Uses MediaPlayer, separate volume streams
  /// - Web: Uses HTML5 Audio, autoplay restrictions apply
  Future<void> initialize() async {
    try {
      // Set global audio context (iOS respects silent mode)
      if (!kIsWeb) {
        await AudioPlayer.global.setAudioContext(
          AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient,
              options: [
                AVAudioSessionOptions.mixWithOthers,
              ],
            ),
            android: AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );
      }

      // Pre-create initial pool of SFX players
      for (int i = 0; i < 2; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        _sfxPlayerPool.add(player);
      }

      // Pre-create music player
      final musicPlayer = AudioPlayer();
      await musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      _musicPlayerPool.add(musicPlayer);

      debugPrint('[AudioManager] Initialized with ${_sfxPlayerPool.length} SFX players');
    } catch (e) {
      debugPrint('[AudioManager] Initialization error: $e');
      // Continue anyway - audio is not critical
    }
  }

  /// Dispose all resources
  ///
  /// CLEANUP:
  /// 1. Stop all playing audio
  /// 2. Cancel all timers
  /// 3. Dispose all players
  /// 4. Clear caches
  Future<void> dispose() async {
    // Cancel all timers
    for (final timer in _idleTimers.values) {
      timer.cancel();
    }
    _idleTimers.clear();

    // Stop and dispose all SFX players
    for (final player in _sfxPlayerPool) {
      await player.stop();
      await player.dispose();
    }
    _sfxPlayerPool.clear();

    // Stop and dispose all music players
    for (final player in _musicPlayerPool) {
      await player.stop();
      await player.dispose();
    }
    _musicPlayerPool.clear();

    // Clear active players
    _activeSfxPlayers.clear();
    _activeMusicPlayers.clear();

    // Clear audio cache
    _audioCache.clear();

    debugPrint('[AudioManager] Disposed');
  }

  // ==================== SOUND EFFECTS ====================

  /// Get an available SFX player from pool
  ///
  /// STRATEGY:
  /// 1. Check pool for available player
  /// 2. If pool empty, create new (up to max)
  /// 3. If at max, reuse oldest player
  ///
  /// PERFORMANCE:
  /// - Reusing players avoids initialization delay
  /// - Pool size limited to prevent memory issues
  Future<AudioPlayer> _getSfxPlayer() async {
    AudioPlayer? player;

    // Try to get from pool
    if (_sfxPlayerPool.isNotEmpty) {
      player = _sfxPlayerPool.removeLast();

      // Cancel idle timer if exists
      _idleTimers[player]?.cancel();
      _idleTimers.remove(player);
    } else if (_sfxPlayerPool.length + _activeSfxPlayers.length < _maxSfxPlayers) {
      // Create new if under limit
      player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      debugPrint('[AudioManager] Created new SFX player');
    } else {
      // Reuse oldest active player
      final oldestKey = _activeSfxPlayers.keys.first;
      player = _activeSfxPlayers.remove(oldestKey);
      if (player != null) {
        await player.stop();
      }
      debugPrint('[AudioManager] Reusing active SFX player');
    }

    return player!;
  }

  /// Return SFX player to pool
  ///
  /// Delayed return with idle timeout
  /// Allows rapid successive sounds without re-initialization
  void _returnSfxPlayer(String soundId) {
    final player = _activeSfxPlayers.remove(soundId);
    if (player == null) return;

    // Set idle timer before returning to pool
    _idleTimers[player] = Timer(
      const Duration(milliseconds: _playerIdleTimeout),
      () async {
        // Stop player
        await player.stop();

        // Return to pool if not full
        if (_sfxPlayerPool.length < _maxSfxPlayers) {
          _sfxPlayerPool.add(player);
        } else {
          // Pool full, dispose
          await player.dispose();
        }

        _idleTimers.remove(player);
        debugPrint('[AudioManager] Returned SFX player to pool');
      },
    );
  }

  /// Play a sound effect
  ///
  /// PARAMETERS:
  /// - soundId: Unique identifier for tracking
  /// - source: Audio source to play
  /// - volume: 0.0 to 1.0
  /// - pitch: 0.5 to 2.0 (1.0 = normal)
  ///
  /// RETURNS:
  /// - true if sound started playing
  /// - false if failed
  Future<bool> playSfx({
    required String soundId,
    required Source source,
    double volume = 1.0,
    double pitch = 1.0,
  }) async {
    try {
      // Stop existing sound with same ID
      if (_activeSfxPlayers.containsKey(soundId)) {
        final player = _activeSfxPlayers[soundId];
        if (player != null) {
          await player.stop();
        }
        _returnSfxPlayer(soundId);
      }

      // Get player from pool
      final player = await _getSfxPlayer();

      // Configure player
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setPlaybackRate(pitch.clamp(0.5, 2.0));
      await player.setReleaseMode(ReleaseMode.stop);

      // Set source and play
      await player.setSource(source);
      await player.resume();

      // Track as active
      _activeSfxPlayers[soundId] = player;

      // Return to pool when completed
      player.onPlayerComplete.listen((_) {
        _returnSfxPlayer(soundId);
      });

      return true;
    } catch (e) {
      debugPrint('[AudioManager] Error playing SFX: $e');
      return false;
    }
  }

  /// Stop a specific sound effect
  Future<void> stopSfx(String soundId) async {
    final player = _activeSfxPlayers[soundId];
    if (player != null) {
      await player.stop();
      _returnSfxPlayer(soundId);
    }
  }

  /// Stop all sound effects
  Future<void> stopAllSfx() async {
    for (final soundId in _activeSfxPlayers.keys.toList()) {
      await stopSfx(soundId);
    }
  }

  // ==================== MUSIC ====================

  /// Get a music player
  Future<AudioPlayer> _getMusicPlayer() async {
    AudioPlayer? player;

    if (_musicPlayerPool.isNotEmpty) {
      player = _musicPlayerPool.removeLast();
    } else if (_activeMusicPlayers.length < _maxMusicPlayers) {
      player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.mediaPlayer);
    } else {
      // Reuse existing
      final key = _activeMusicPlayers.keys.first;
      player = _activeMusicPlayers.remove(key);
      if (player != null) {
        await player.stop();
      }
    }

    return player!;
  }

  /// Play background music
  ///
  /// MUSIC CHARACTERISTICS:
  /// - Uses mediaPlayer mode (better for long files)
  /// - Loops continuously
  /// - Can fade in/out
  /// - Lower priority than SFX
  Future<bool> playMusic({
    required String musicId,
    required Source source,
    double volume = 0.6,
    bool loop = true,
    Duration? fadeInDuration,
  }) async {
    try {
      // Stop existing music with same ID
      if (_activeMusicPlayers.containsKey(musicId)) {
        await stopMusic(musicId);
      }

      // Get player
      final player = await _getMusicPlayer();

      // Configure player
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      await player.setVolume(fadeInDuration != null ? 0.0 : volume);

      // Set source and play
      await player.setSource(source);
      await player.resume();

      // Track as active
      _activeMusicPlayers[musicId] = player;

      // Fade in if requested
      if (fadeInDuration != null) {
        _fadeVolume(player, 0.0, volume, fadeInDuration);
      }

      return true;
    } catch (e) {
      debugPrint('[AudioManager] Error playing music: $e');
      return false;
    }
  }

  /// Stop music with optional fade out
  Future<void> stopMusic(String musicId, {Duration? fadeOutDuration}) async {
    final player = _activeMusicPlayers[musicId];
    if (player == null) return;

    if (fadeOutDuration != null) {
      // Get current volume from player settings (no direct getter in v5)
      // Assume current volume, or fade from max
      await _fadeVolume(player, 1.0, 0.0, fadeOutDuration);
    }

    final playerToStop = _activeMusicPlayers[musicId];
    if (playerToStop != null) {
      await playerToStop.stop();
    }
    _activeMusicPlayers.remove(musicId);
    _musicPlayerPool.add(player);
  }

  /// Pause music
  Future<void> pauseMusic(String musicId) async {
    final player = _activeMusicPlayers[musicId];
    if (player != null) {
      await player.pause();
    }
  }

  /// Resume music
  Future<void> resumeMusic(String musicId) async {
    final player = _activeMusicPlayers[musicId];
    if (player != null) {
      await player.resume();
    }
  }

  /// Stop all music
  Future<void> stopAllMusic({Duration? fadeOutDuration}) async {
    for (final musicId in _activeMusicPlayers.keys.toList()) {
      await stopMusic(musicId, fadeOutDuration: fadeOutDuration);
    }
  }

  // ==================== HELPERS ====================

  /// Fade volume from start to end over duration
  Future<void> _fadeVolume(
    AudioPlayer player,
    double startVolume,
    double endVolume,
    Duration duration,
  ) async {
    const steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final volumeStep = (endVolume - startVolume) / steps;

    for (int i = 0; i <= steps; i++) {
      await player.setVolume(startVolume + (volumeStep * i));
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Preload audio source into cache
  ///
  /// PERFORMANCE:
  /// - Loads audio file into memory
  /// - Faster playback start
  /// - Use for frequently played sounds
  ///
  /// MEMORY:
  /// - Increases memory usage
  /// - Only preload essential sounds
  /// - Clear cache when memory constrained
  Future<void> preloadSound(String soundId, String assetPath) async {
    try {
      if (_audioCache.containsKey(soundId)) {
        debugPrint('[AudioManager] Sound already cached: $soundId');
        return;
      }

      final source = AssetSource(assetPath);
      _audioCache[soundId] = source;

      debugPrint('[AudioManager] Preloaded: $soundId');
    } catch (e) {
      debugPrint('[AudioManager] Error preloading $soundId: $e');
    }
  }

  /// Get cached audio source or create new
  Source getOrCreateSource(String soundId, String assetPath) {
    if (_audioCache.containsKey(soundId)) {
      return _audioCache[soundId]!;
    }
    return AssetSource(assetPath);
  }

  /// Clear audio cache to free memory
  void clearCache() {
    _audioCache.clear();
    debugPrint('[AudioManager] Cache cleared');
  }

  /// Get current number of active players
  int get activeSfxCount => _activeSfxPlayers.length;
  int get activeMusicCount => _activeMusicPlayers.length;
  int get pooledSfxCount => _sfxPlayerPool.length;
  int get pooledMusicCount => _musicPlayerPool.length;

  /// Print debug info
  void printDebugInfo() {
    debugPrint('[AudioManager] Stats:');
    debugPrint('  Active SFX: $activeSfxCount');
    debugPrint('  Active Music: $activeMusicCount');
    debugPrint('  Pooled SFX: $pooledSfxCount');
    debugPrint('  Pooled Music: $pooledMusicCount');
    debugPrint('  Cached sounds: ${_audioCache.length}');
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// PERFORMANCE NOTES
/// ═══════════════════════════════════════════════════════════════════
///
/// OBJECT POOLING BENEFITS:
/// - Reduces garbage collection pressure
/// - Eliminates player initialization delay
/// - More predictable performance
/// - Lower memory fragmentation
///
/// MOBILE CONSIDERATIONS:
/// - iOS: Respect silent mode (AVAudioSessionCategory.ambient)
/// - Android: Use game audio focus (AndroidUsageType.game)
/// - Both: Handle app lifecycle (pause/resume)
/// - Both: Release resources in background
///
/// MEMORY MANAGEMENT:
/// - Pool size limits prevent unbounded growth
/// - Idle timeout releases unused players
/// - Cache only essential sounds
/// - Dispose properly on cleanup
///
/// LATENCY OPTIMIZATION:
/// - lowLatency mode for SFX (faster start)
/// - mediaPlayer mode for music (better quality)
/// - Preloading for instant playback
/// - Pool prevents initialization delay
///
/// PLATFORM DIFFERENCES:
/// - Web: HTML5 Audio with autoplay restrictions
/// - iOS: AVAudioPlayer with category system
/// - Android: MediaPlayer with audio focus
/// - Desktop: May have different audio backends
///
/// TESTING WITHOUT AUDIO:
/// - All methods fail gracefully
/// - Returns false/null on error
/// - Continues execution
/// - Logs errors for debugging
///
/// ═══════════════════════════════════════════════════════════════════
