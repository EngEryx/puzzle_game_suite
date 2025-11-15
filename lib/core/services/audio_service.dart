import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_manager.dart';
import 'settings_service.dart';
import 'dart:math' as math;

/// Audio service for game sound effects and music.
///
/// ═══════════════════════════════════════════════════════════════════
/// AUDIO SERVICE: Game Sound & Music Management
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Centralized audio management for consistent sound experience.
///
/// DESIGN PRINCIPLES:
/// 1. CENTRALIZED:
///    - Single source of truth for audio
///    - Consistent volume/pitch
///    - Easy to enable/disable globally
///
/// 2. CONTEXT-AWARE:
///    - Different sounds for different actions
///    - Layered audio (music + SFX)
///    - Priority system (important sounds override)
///
/// 3. PERFORMANCE:
///    - Preload sounds on init
///    - Pool for frequently used sounds
///    - Cancel sounds when not needed
///
/// 4. USER CONTROL:
///    - Respect device settings
///    - Volume controls
///    - Mute option
///    - Separate music/SFX toggles
///
/// AUDIO PSYCHOLOGY:
/// - Positive sounds reinforce success
/// - Error sounds prevent frustration (clear feedback)
/// - Background music sets mood
/// - Silence can be powerful (don't overdo it)
///
/// IMPLEMENTATION PLAN:
/// Week 1: Empty stubs (this file)
/// Week 2: Full implementation with:
///   - audioplayers package
///   - Sound asset loading
///   - Volume management
///   - Settings integration
///
/// SIMILAR PATTERNS:
/// - Unity AudioManager
/// - Web Audio API
/// - iOS AVAudioPlayer
/// - Game engine sound systems
///
/// ═══════════════════════════════════════════════════════════════════
class AudioService {
  /// Audio manager instance
  final AudioManager _audioManager = AudioManager.instance;

  /// Settings service for reading audio preferences
  final SettingsService _settingsService;

  /// Random generator for pitch variation
  final math.Random _random = math.Random();

  /// Whether service is initialized
  bool _initialized = false;

  AudioService(this._settingsService);

  // ==================== GETTERS ====================
  // Read settings from SettingsService instead of local state

  bool get sfxEnabled => _settingsService.settings.sfxEnabled;
  bool get musicEnabled => _settingsService.settings.musicEnabled;
  double get masterVolume => _settingsService.settings.masterVolume;
  double get sfxVolume => _settingsService.settings.sfxVolume;
  double get musicVolume => _settingsService.settings.musicVolume;

  // ==================== SETTERS ====================
  // These are now deprecated - use SettingsController instead
  // Kept for backwards compatibility

  @Deprecated('Use SettingsController.toggleSfx() instead')
  void setSfxEnabled(bool enabled) {
    // This method is deprecated - settings should be changed through SettingsController
    print('[AudioService] Warning: setSfxEnabled is deprecated. Use SettingsController.toggleSfx() instead.');
  }

  @Deprecated('Use SettingsController.toggleMusic() instead')
  void setMusicEnabled(bool enabled) {
    // This method is deprecated - settings should be changed through SettingsController
    print('[AudioService] Warning: setMusicEnabled is deprecated. Use SettingsController.toggleMusic() instead.');
  }

  @Deprecated('Use SettingsController.updateMasterVolume() instead')
  void setMasterVolume(double volume) {
    // This method is deprecated - settings should be changed through SettingsController
    print('[AudioService] Warning: setMasterVolume is deprecated. Use SettingsController.updateMasterVolume() instead.');
  }

  @Deprecated('Use SettingsController.updateSfxVolume() instead')
  void setSfxVolume(double volume) {
    // This method is deprecated - settings should be changed through SettingsController
    print('[AudioService] Warning: setSfxVolume is deprecated. Use SettingsController.updateSfxVolume() instead.');
  }

  @Deprecated('Use SettingsController.updateMusicVolume() instead')
  void setMusicVolume(double volume) {
    // This method is deprecated - settings should be changed through SettingsController
    print('[AudioService] Warning: setMusicVolume is deprecated. Use SettingsController.updateMusicVolume() instead.');
  }

  // ==================== INITIALIZATION ====================

  /// Initialize audio service
  ///
  /// STEPS:
  /// 1. Load sound assets
  /// 2. Create audio pools
  /// 3. Settings are read from SettingsService
  /// 4. Start background music (if enabled)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize audio manager
      await _audioManager.initialize();

      // Preload common sounds (if they exist)
      // These will fail gracefully if files don't exist
      await _preloadSounds();

      _initialized = true;
      print('[AudioService] Initialized successfully');
    } catch (e) {
      print('[AudioService] Initialization warning: $e');
      // Continue anyway - audio is not critical for app function
      _initialized = true;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioManager.stopAllSfx();
    await _audioManager.stopAllMusic();
    await _audioManager.dispose();
    _initialized = false;
    print('[AudioService] Disposed');
  }

  /// Preload common sounds for instant playback
  Future<void> _preloadSounds() async {
    try {
      // Preload common sounds (gracefully handles missing files)
      final soundsToPreload = {
        'move': 'sounds/pour.mp3',
        'win_basic': 'sounds/win.mp3',
        'win_good': 'sounds/win_good.mp3',
        'win_perfect': 'sounds/win_perfect.mp3',
        'error': 'sounds/error.mp3',
        'undo': 'sounds/undo.mp3',
        'button_tap': 'sounds/click.mp3',
      };

      for (final entry in soundsToPreload.entries) {
        try {
          await _audioManager.preloadSound(entry.key, entry.value);
        } catch (e) {
          // Individual sound load failures are logged but don't stop initialization
          print('[AudioService] Could not preload ${entry.key}: $e');
        }
      }

      print('[AudioService] Sound preloading completed');
    } catch (e) {
      // Overall preloading error - log and continue
      print('[AudioService] Preloading warning: $e');
    }
  }

  // ==================== SOUND EFFECTS ====================

  /// Play move sound
  ///
  /// WHEN: User pours colors between containers
  ///
  /// CHARACTER:
  /// - Short (100-200ms)
  /// - Satisfying "pour" or "splash" sound
  /// - Positive tone (reward for action)
  ///
  /// AUDIO DESIGN:
  /// - Frequency: 500-2000 Hz (mid-range, clear)
  /// - Volume: Medium (not too loud)
  /// - Variation: Slight pitch randomization for variety
  void playMove() {
    if (!sfxEnabled || !_initialized) return;

    try {
      // Add slight pitch variation for variety (0.95 to 1.05)
      final pitch = 0.95 + (_random.nextDouble() * 0.1);
      _playSound(
        'move',
        assetPath: 'sounds/pour.mp3',
        volume: sfxVolume * masterVolume,
        pitch: pitch,
      );
    } catch (e) {
      // Audio errors should never crash the app
      print('[AudioService] Error playing move sound: $e');
    }
  }

  /// Play win sound
  ///
  /// WHEN: Level completed successfully
  ///
  /// CHARACTER:
  /// - Medium length (500-1000ms)
  /// - Celebratory, triumphant
  /// - Rising pitch (creates excitement)
  /// - Reward sound (dopamine trigger)
  ///
  /// AUDIO DESIGN:
  /// - Frequency: Rising (500 → 2000 Hz)
  /// - Volume: Louder than normal (emphasize achievement)
  /// - May include: chimes, bells, fanfare
  ///
  /// VARIATIONS BY STARS:
  /// - 1 star: Basic chime
  /// - 2 stars: Double chime
  /// - 3 stars: Full fanfare with flourish
  void playWin({int stars = 1}) {
    if (!sfxEnabled || !_initialized) return;

    try {
      // Play appropriate win sound based on stars
      // Volume slightly louder to emphasize achievement
      final volume = (sfxVolume * masterVolume * 1.2).clamp(0.0, 1.0);
      switch (stars) {
        case 3:
          _playSound('win_perfect', assetPath: 'sounds/win_perfect.mp3', volume: volume);
        case 2:
          _playSound('win_good', assetPath: 'sounds/win_good.mp3', volume: volume);
        default:
          _playSound('win_basic', assetPath: 'sounds/win.mp3', volume: volume);
      }
    } catch (e) {
      print('[AudioService] Error playing win sound: $e');
    }
  }

  /// Play error sound
  ///
  /// WHEN: Invalid move attempted
  ///
  /// CHARACTER:
  /// - Very short (50-100ms)
  /// - Not harsh (avoid frustration)
  /// - Clear "no" signal
  /// - Informative, not punishing
  ///
  /// AUDIO DESIGN:
  /// - Frequency: Low (200-500 Hz, gentle)
  /// - Volume: Quieter than positive sounds
  /// - Tone: Neutral/gentle decline
  /// - May include: soft "bonk" or "thud"
  ///
  /// AVOID:
  /// - Harsh buzzer sounds (creates negative emotion)
  /// - Long error sounds (annoying)
  /// - High-pitched sounds (piercing/stressful)
  ///
  /// PRINCIPLE: Communicate error without punishment
  void playError() {
    if (!sfxEnabled || !_initialized) return;

    try {
      // Play error sound at reduced volume (less punishing)
      _playSound(
        'error',
        assetPath: 'sounds/error.mp3',
        volume: sfxVolume * masterVolume * 0.7,
      );
    } catch (e) {
      print('[AudioService] Error playing error sound: $e');
    }
  }

  /// Play undo sound
  ///
  /// WHEN: Move is undone
  ///
  /// CHARACTER:
  /// - Short (100-150ms)
  /// - "Reverse" feel (descending pitch)
  /// - Neutral tone (not positive or negative)
  void playUndo() {
    if (!sfxEnabled || !_initialized) return;

    try {
      // Play undo with slightly lower pitch for "reverse" feel
      _playSound(
        'undo',
        assetPath: 'sounds/undo.mp3',
        volume: sfxVolume * masterVolume,
        pitch: 0.9,
      );
    } catch (e) {
      print('[AudioService] Error playing undo sound: $e');
    }
  }

  /// Play button tap sound
  ///
  /// WHEN: UI button pressed
  ///
  /// CHARACTER:
  /// - Very short (30-50ms)
  /// - Subtle click
  /// - Tactile feedback
  void playButtonTap() {
    if (!sfxEnabled || !_initialized) return;

    try {
      // Play at reduced volume for subtle feedback
      _playSound(
        'button_tap',
        assetPath: 'sounds/click.mp3',
        volume: sfxVolume * masterVolume * 0.5,
      );
    } catch (e) {
      print('[AudioService] Error playing button tap sound: $e');
    }
  }

  /// Play level start sound
  ///
  /// WHEN: Level begins
  ///
  /// CHARACTER:
  /// - Short-medium (200-300ms)
  /// - Energetic, ready-to-go
  /// - Signals beginning
  void playLevelStart() {
    if (!sfxEnabled || !_initialized) return;

    // TODO: Add level_start.mp3 sound file
    // For now, disabled as the file doesn't exist yet
    // _playSound(
    //   'level_start',
    //   assetPath: 'sounds/level_start.mp3',
    //   volume: sfxVolume * masterVolume,
    // );
  }

  // ==================== MUSIC ====================

  /// Start background music
  ///
  /// MUSIC DESIGN:
  /// - Looping track
  /// - Non-intrusive (doesn't distract from gameplay)
  /// - Tempo: Moderate (not too slow, not too fast)
  /// - Mood: Calm, focused, pleasant
  /// - Style: Ambient, instrumental, puzzle-appropriate
  ///
  /// CONSIDERATIONS:
  /// - Must loop seamlessly
  /// - Volume should be lower than SFX
  /// - Should fade in/out smoothly
  /// - User can disable separately from SFX
  void startBackgroundMusic() {
    if (!musicEnabled || !_initialized) return;

    try {
      // Note: background.mp3 doesn't exist yet - will fail gracefully
      _playMusic(
        'background',
        assetPath: 'sounds/background.mp3',
        volume: musicVolume * masterVolume,
        loop: true,
        fadeIn: const Duration(milliseconds: 1000),
      );
    } catch (e) {
      print('[AudioService] Background music not available: $e');
    }
  }

  /// Stop background music
  void stopBackgroundMusic() {
    _audioManager.stopMusic(
      'background',
      fadeOutDuration: const Duration(milliseconds: 500),
    );
  }

  /// Pause background music
  ///
  /// Used when app goes to background
  void pauseBackgroundMusic() {
    _audioManager.pauseMusic('background');
  }

  /// Resume background music
  ///
  /// Used when app returns to foreground
  void resumeBackgroundMusic() {
    if (!musicEnabled || !_initialized) return;
    _audioManager.resumeMusic('background');
  }

  // ==================== HELPERS ====================

  /// Play a sound by name
  ///
  /// Internal helper that handles the actual sound playback
  void _playSound(
    String soundId, {
    required String assetPath,
    double volume = 1.0,
    double pitch = 1.0,
  }) {
    if (!_initialized) return;

    try {
      // Get or create audio source
      final source = _audioManager.getOrCreateSource(soundId, assetPath);

      // Play sound through audio manager
      _audioManager.playSfx(
        soundId: soundId,
        source: source,
        volume: volume.clamp(0.0, 1.0),
        pitch: pitch.clamp(0.5, 2.0),
      );
    } catch (e) {
      // Fail gracefully - audio errors shouldn't crash the app
      print('[AudioService] Error playing sound $soundId: $e');
    }
  }

  /// Play music by name
  ///
  /// Internal helper for music playback
  void _playMusic(
    String musicId, {
    required String assetPath,
    bool loop = false,
    double volume = 1.0,
    Duration? fadeIn,
  }) {
    if (!_initialized) return;

    try {
      // Get or create audio source
      final source = _audioManager.getOrCreateSource(musicId, assetPath);

      // Play music through audio manager
      _audioManager.playMusic(
        musicId: musicId,
        source: source,
        volume: volume.clamp(0.0, 1.0),
        loop: loop,
        fadeInDuration: fadeIn,
      );
    } catch (e) {
      print('[AudioService] Error playing music $musicId: $e');
    }
  }
}

/// Provider for audio service
///
/// USAGE:
/// ```dart
/// // Play sound
/// ref.read(audioServiceProvider).playMove();
///
/// // Change settings (use SettingsController)
/// ref.read(settingsControllerProvider.notifier).toggleSfx();
///
/// // Watch setting
/// final sfxEnabled = ref.watch(audioServiceProvider).sfxEnabled;
/// ```
final audioServiceProvider = Provider<AudioService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  final service = AudioService(settingsService);

  // Initialize on first access
  service.initialize();

  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// ═══════════════════════════════════════════════════════════════════
/// IMPLEMENTATION ROADMAP
/// ═══════════════════════════════════════════════════════════════════
///
/// WEEK 1 (Current):
/// ✓ Service structure
/// ✓ Method signatures
/// ✓ Documentation
/// ✓ Provider setup
/// ✓ Settings structure
///
/// WEEK 2 (TODO):
/// □ Install audioplayers package
/// □ Add sound assets
/// □ Implement _playSound()
/// □ Implement _playMusic()
/// □ Implement all sound methods
/// □ Add sound pools
/// □ Load user preferences
/// □ Settings UI integration
/// □ Test on iOS/Android
/// □ Optimize performance
///
/// WEEK 3+ (Future):
/// □ Advanced features:
///   - Sound variations (randomize pitch)
///   - 3D spatial audio
///   - Dynamic music (changes with gameplay)
///   - Adaptive volume (game state)
///   - Sound themes (let user choose)
///   - Custom sound packs
///
/// ═══════════════════════════════════════════════════════════════════
/// AUDIO ASSETS NEEDED
/// ═══════════════════════════════════════════════════════════════════
///
/// SOUND EFFECTS (assets/sounds/):
/// - move.mp3           (pour/splash, 100-200ms)
/// - win_basic.mp3      (1 star, 500ms)
/// - win_good.mp3       (2 stars, 700ms)
/// - win_perfect.mp3    (3 stars, 1000ms)
/// - error.mp3          (gentle thud, 50-100ms)
/// - undo.mp3           (reverse pour, 100-150ms)
/// - button_tap.mp3     (click, 30-50ms)
/// - level_start.mp3    (energetic start, 200-300ms)
///
/// MUSIC (assets/music/):
/// - background.mp3     (looping ambient, 2-3 min)
/// - menu.mp3           (looping menu music, 1-2 min)
///
/// FILE FORMAT RECOMMENDATIONS:
/// - Use MP3 for compatibility (iOS/Android)
/// - Keep files small (compress appropriately)
/// - Sample rate: 44.1 kHz (standard)
/// - Bit rate: 128 kbps (good balance)
/// - Normalize audio levels
///
/// FREE RESOURCES:
/// - Freesound.org (CC-licensed)
/// - OpenGameArt.org
/// - Incompetech.com (music)
/// - JSFXR (generate simple game sounds)
/// - Audacity (edit audio)
///
/// ═══════════════════════════════════════════════════════════════════
/// AUDIO BEST PRACTICES
/// ═══════════════════════════════════════════════════════════════════
///
/// 1. VOLUME HIERARCHY:
///    - Error sounds: Quietest (don't punish)
///    - Regular SFX: Medium
///    - Win sounds: Loudest (celebrate!)
///    - Music: Background (don't compete with SFX)
///
/// 2. FREQUENCY BALANCE:
///    - Use different frequency ranges for different sounds
///    - Avoid frequency masking (sounds covering each other)
///    - Test with headphones AND speakers
///
/// 3. VARIATION:
///    - Randomize pitch slightly (prevent repetition fatigue)
///    - Use sound variations for repeated actions
///    - Don't play same sound too frequently
///
/// 4. CONTEXT:
///    - Mute when app in background
///    - Respect system volume/mute
///    - Fade in/out smoothly
///    - Stop when appropriate (don't let sounds pile up)
///
/// 5. ACCESSIBILITY:
///    - Provide visual alternatives
///    - Don't rely solely on audio for feedback
///    - Test without sound
///    - Support hearing-impaired users
///
/// 6. PERFORMANCE:
///    - Preload frequently used sounds
///    - Use sound pools (reuse instances)
///    - Limit simultaneous sounds
///    - Cancel sounds when not needed
///
/// 7. TESTING:
///    - Test on real devices
///    - Test with headphones
///    - Test in noisy environments
///    - Test volume extremes
///    - Test rapid sound triggering
///
/// ═══════════════════════════════════════════════════════════════════
