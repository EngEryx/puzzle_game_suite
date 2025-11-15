import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_theme.dart';

/// Service for managing application settings with persistence.
///
/// ARCHITECTURE PATTERN: Repository Pattern
///
/// This service handles all application settings including:
/// - Audio preferences (volume levels, toggles)
/// - Visual preferences (theme, effects, animations)
/// - Gameplay preferences (difficulty, timers, hints)
/// - Accessibility options
///
/// DATA PERSISTENCE:
/// Uses SharedPreferences for lightweight key-value storage.
/// All settings are saved immediately on change for data safety.
///
/// MIGRATION STRATEGY:
/// - Version number tracks settings schema version
/// - Migrations run on init if version mismatch detected
/// - Backward compatible - missing keys use defaults
///
/// USAGE:
/// ```dart
/// final settingsService = ref.read(settingsServiceProvider);
/// await settingsService.init();
/// final settings = settingsService.settings;
/// ```
class SettingsService {
  // Storage keys
  static const String _settingsVersion = 'settings_version';
  static const int _currentVersion = 1;

  // Audio keys
  static const String _masterVolumeKey = 'audio_master_volume';
  static const String _sfxVolumeKey = 'audio_sfx_volume';
  static const String _musicVolumeKey = 'audio_music_volume';
  static const String _sfxEnabledKey = 'audio_sfx_enabled';
  static const String _musicEnabledKey = 'audio_music_enabled';
  static const String _hapticsEnabledKey = 'audio_haptics_enabled';

  // Visual keys
  static const String _themeTypeKey = 'visual_theme_type';
  static const String _particleEffectsKey = 'visual_particle_effects';
  static const String _animationsEnabledKey = 'visual_animations_enabled';
  static const String _reducedMotionKey = 'visual_reduced_motion';
  static const String _brightnessKey = 'visual_brightness';

  // Gameplay keys
  static const String _hintCooldownKey = 'gameplay_hint_cooldown';
  static const String _showTimerKey = 'gameplay_show_timer';
  static const String _autoSaveKey = 'gameplay_auto_save';
  static const String _confirmUndoKey = 'gameplay_confirm_undo';
  static const String _showMovesCountKey = 'gameplay_show_moves_count';

  // Monetization keys
  static const String _adsRemovedKey = 'monetization_ads_removed';

  /// SharedPreferences instance
  late final SharedPreferences _prefs;

  /// Current settings (cached in memory)
  Settings _settings = const Settings();

  /// Whether the service has been initialized
  bool _initialized = false;

  /// Get current settings
  Settings get settings => _settings;

  /// Check if initialized
  bool get initialized => _initialized;

  /// Initialize the service
  ///
  /// MUST be called before using any other methods.
  /// Loads settings from storage and runs migrations if needed.
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();

    // Check and run migrations if needed
    await _runMigrations();

    // Load all settings
    _loadSettings();

    _initialized = true;
    print('[SettingsService] Initialized successfully');
  }

  /// Load all settings from storage
  void _loadSettings() {
    _settings = Settings(
      // Audio settings
      masterVolume: _prefs.getDouble(_masterVolumeKey) ?? 1.0,
      sfxVolume: _prefs.getDouble(_sfxVolumeKey) ?? 1.0,
      musicVolume: _prefs.getDouble(_musicVolumeKey) ?? 0.6,
      sfxEnabled: _prefs.getBool(_sfxEnabledKey) ?? true,
      musicEnabled: _prefs.getBool(_musicEnabledKey) ?? true,
      hapticsEnabled: _prefs.getBool(_hapticsEnabledKey) ?? true,

      // Visual settings
      themeType: ThemeType.values[_prefs.getInt(_themeTypeKey) ?? 0],
      particleEffects: _prefs.getBool(_particleEffectsKey) ?? true,
      animationsEnabled: _prefs.getBool(_animationsEnabledKey) ?? true,
      reducedMotion: _prefs.getBool(_reducedMotionKey) ?? false,
      brightness: Brightness.values[_prefs.getInt(_brightnessKey) ?? 0],

      // Gameplay settings
      hintCooldownSeconds: _prefs.getInt(_hintCooldownKey) ?? 30,
      showTimer: _prefs.getBool(_showTimerKey) ?? false,
      autoSave: _prefs.getBool(_autoSaveKey) ?? true,
      confirmUndo: _prefs.getBool(_confirmUndoKey) ?? false,
      showMovesCount: _prefs.getBool(_showMovesCountKey) ?? true,

      // Monetization settings
      adsRemoved: _prefs.getBool(_adsRemovedKey) ?? false,
    );
  }

  /// Run migrations if settings version has changed
  Future<void> _runMigrations() async {
    final storedVersion = _prefs.getInt(_settingsVersion) ?? 0;

    if (storedVersion < _currentVersion) {
      print('[SettingsService] Running migrations from v$storedVersion to v$_currentVersion');

      // Run migrations in sequence
      if (storedVersion < 1) {
        await _migrateToV1();
      }

      // Future migrations go here
      // if (storedVersion < 2) {
      //   await _migrateToV2();
      // }

      // Update version
      await _prefs.setInt(_settingsVersion, _currentVersion);
    }
  }

  /// Migration to version 1 (initial version)
  Future<void> _migrateToV1() async {
    // This is the initial version, so just ensure defaults exist
    // No actual migration needed
    print('[SettingsService] Initialized to v1');
  }

  // ==================== UPDATE METHODS ====================

  /// Update master volume
  Future<void> updateMasterVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _settings = _settings.copyWith(masterVolume: clamped);
    await _prefs.setDouble(_masterVolumeKey, clamped);
  }

  /// Update SFX volume
  Future<void> updateSfxVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _settings = _settings.copyWith(sfxVolume: clamped);
    await _prefs.setDouble(_sfxVolumeKey, clamped);
  }

  /// Update music volume
  Future<void> updateMusicVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _settings = _settings.copyWith(musicVolume: clamped);
    await _prefs.setDouble(_musicVolumeKey, clamped);
  }

  /// Update SFX enabled
  Future<void> updateSfxEnabled(bool enabled) async {
    _settings = _settings.copyWith(sfxEnabled: enabled);
    await _prefs.setBool(_sfxEnabledKey, enabled);
  }

  /// Update music enabled
  Future<void> updateMusicEnabled(bool enabled) async {
    _settings = _settings.copyWith(musicEnabled: enabled);
    await _prefs.setBool(_musicEnabledKey, enabled);
  }

  /// Update haptics enabled
  Future<void> updateHapticsEnabled(bool enabled) async {
    _settings = _settings.copyWith(hapticsEnabled: enabled);
    await _prefs.setBool(_hapticsEnabledKey, enabled);
  }

  /// Update theme type
  Future<void> updateThemeType(ThemeType theme) async {
    _settings = _settings.copyWith(themeType: theme);
    await _prefs.setInt(_themeTypeKey, theme.index);
  }

  /// Update particle effects
  Future<void> updateParticleEffects(bool enabled) async {
    _settings = _settings.copyWith(particleEffects: enabled);
    await _prefs.setBool(_particleEffectsKey, enabled);
  }

  /// Update animations enabled
  Future<void> updateAnimationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(animationsEnabled: enabled);
    await _prefs.setBool(_animationsEnabledKey, enabled);
  }

  /// Update reduced motion
  Future<void> updateReducedMotion(bool enabled) async {
    _settings = _settings.copyWith(reducedMotion: enabled);
    await _prefs.setBool(_reducedMotionKey, enabled);
  }

  /// Update brightness
  Future<void> updateBrightness(Brightness brightness) async {
    _settings = _settings.copyWith(brightness: brightness);
    await _prefs.setInt(_brightnessKey, brightness.index);
  }

  /// Update hint cooldown
  Future<void> updateHintCooldown(int seconds) async {
    final clamped = seconds.clamp(10, 300); // 10s to 5min
    _settings = _settings.copyWith(hintCooldownSeconds: clamped);
    await _prefs.setInt(_hintCooldownKey, clamped);
  }

  /// Update show timer
  Future<void> updateShowTimer(bool enabled) async {
    _settings = _settings.copyWith(showTimer: enabled);
    await _prefs.setBool(_showTimerKey, enabled);
  }

  /// Update auto save
  Future<void> updateAutoSave(bool enabled) async {
    _settings = _settings.copyWith(autoSave: enabled);
    await _prefs.setBool(_autoSaveKey, enabled);
  }

  /// Update confirm undo
  Future<void> updateConfirmUndo(bool enabled) async {
    _settings = _settings.copyWith(confirmUndo: enabled);
    await _prefs.setBool(_confirmUndoKey, enabled);
  }

  /// Update show moves count
  Future<void> updateShowMovesCount(bool enabled) async {
    _settings = _settings.copyWith(showMovesCount: enabled);
    await _prefs.setBool(_showMovesCountKey, enabled);
  }

  /// Update ads removed
  Future<void> updateAdsRemoved(bool enabled) async {
    _settings = _settings.copyWith(adsRemoved: enabled);
    await _prefs.setBool(_adsRemovedKey, enabled);
  }

  // ==================== RESET ====================

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _settings = const Settings();

    // Clear all settings from storage
    await _prefs.remove(_masterVolumeKey);
    await _prefs.remove(_sfxVolumeKey);
    await _prefs.remove(_musicVolumeKey);
    await _prefs.remove(_sfxEnabledKey);
    await _prefs.remove(_musicEnabledKey);
    await _prefs.remove(_hapticsEnabledKey);
    await _prefs.remove(_themeTypeKey);
    await _prefs.remove(_particleEffectsKey);
    await _prefs.remove(_animationsEnabledKey);
    await _prefs.remove(_reducedMotionKey);
    await _prefs.remove(_brightnessKey);
    await _prefs.remove(_hintCooldownKey);
    await _prefs.remove(_showTimerKey);
    await _prefs.remove(_autoSaveKey);
    await _prefs.remove(_confirmUndoKey);
    await _prefs.remove(_showMovesCountKey);
    await _prefs.remove(_adsRemovedKey);

    print('[SettingsService] Reset to defaults');
  }

  /// Export settings as JSON for backup
  Map<String, dynamic> exportSettings() {
    return _settings.toJson();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> json) async {
    try {
      _settings = Settings.fromJson(json);

      // Save all settings to storage
      await _prefs.setDouble(_masterVolumeKey, _settings.masterVolume);
      await _prefs.setDouble(_sfxVolumeKey, _settings.sfxVolume);
      await _prefs.setDouble(_musicVolumeKey, _settings.musicVolume);
      await _prefs.setBool(_sfxEnabledKey, _settings.sfxEnabled);
      await _prefs.setBool(_musicEnabledKey, _settings.musicEnabled);
      await _prefs.setBool(_hapticsEnabledKey, _settings.hapticsEnabled);
      await _prefs.setInt(_themeTypeKey, _settings.themeType.index);
      await _prefs.setBool(_particleEffectsKey, _settings.particleEffects);
      await _prefs.setBool(_animationsEnabledKey, _settings.animationsEnabled);
      await _prefs.setBool(_reducedMotionKey, _settings.reducedMotion);
      await _prefs.setInt(_brightnessKey, _settings.brightness.index);
      await _prefs.setInt(_hintCooldownKey, _settings.hintCooldownSeconds);
      await _prefs.setBool(_showTimerKey, _settings.showTimer);
      await _prefs.setBool(_autoSaveKey, _settings.autoSave);
      await _prefs.setBool(_confirmUndoKey, _settings.confirmUndo);
      await _prefs.setBool(_showMovesCountKey, _settings.showMovesCount);
      await _prefs.setBool(_adsRemovedKey, _settings.adsRemoved);

      print('[SettingsService] Imported settings successfully');
    } catch (e) {
      print('[SettingsService] Error importing settings: $e');
      rethrow;
    }
  }
}

/// Settings data model
///
/// Immutable data class containing all application settings.
/// Uses copyWith pattern for updates.
class Settings {
  // Audio settings
  final double masterVolume; // 0.0 to 1.0
  final double sfxVolume; // 0.0 to 1.0
  final double musicVolume; // 0.0 to 1.0
  final bool sfxEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;

  // Visual settings
  final ThemeType themeType;
  final bool particleEffects;
  final bool animationsEnabled;
  final bool reducedMotion; // Accessibility
  final Brightness brightness; // Light/Dark mode

  // Gameplay settings
  final int hintCooldownSeconds; // 10 to 300 seconds
  final bool showTimer;
  final bool autoSave;
  final bool confirmUndo;
  final bool showMovesCount;

  // Monetization settings
  final bool adsRemoved;

  const Settings({
    // Audio defaults
    this.masterVolume = 1.0,
    this.sfxVolume = 1.0,
    this.musicVolume = 0.6,
    this.sfxEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,

    // Visual defaults
    this.themeType = ThemeType.water,
    this.particleEffects = true,
    this.animationsEnabled = true,
    this.reducedMotion = false,
    this.brightness = Brightness.light,

    // Gameplay defaults
    this.hintCooldownSeconds = 30,
    this.showTimer = false,
    this.autoSave = true,
    this.confirmUndo = false,
    this.showMovesCount = true,

    // Monetization defaults
    this.adsRemoved = false,
  });

  /// Create copy with modifications
  Settings copyWith({
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
    bool? sfxEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    ThemeType? themeType,
    bool? particleEffects,
    bool? animationsEnabled,
    bool? reducedMotion,
    Brightness? brightness,
    int? hintCooldownSeconds,
    bool? showTimer,
    bool? autoSave,
    bool? confirmUndo,
    bool? showMovesCount,
    bool? adsRemoved,
  }) {
    return Settings(
      masterVolume: masterVolume ?? this.masterVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      themeType: themeType ?? this.themeType,
      particleEffects: particleEffects ?? this.particleEffects,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      brightness: brightness ?? this.brightness,
      hintCooldownSeconds: hintCooldownSeconds ?? this.hintCooldownSeconds,
      showTimer: showTimer ?? this.showTimer,
      autoSave: autoSave ?? this.autoSave,
      confirmUndo: confirmUndo ?? this.confirmUndo,
      showMovesCount: showMovesCount ?? this.showMovesCount,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'masterVolume': masterVolume,
      'sfxVolume': sfxVolume,
      'musicVolume': musicVolume,
      'sfxEnabled': sfxEnabled,
      'musicEnabled': musicEnabled,
      'hapticsEnabled': hapticsEnabled,
      'themeType': themeType.index,
      'particleEffects': particleEffects,
      'animationsEnabled': animationsEnabled,
      'reducedMotion': reducedMotion,
      'brightness': brightness.index,
      'hintCooldownSeconds': hintCooldownSeconds,
      'showTimer': showTimer,
      'autoSave': autoSave,
      'confirmUndo': confirmUndo,
      'showMovesCount': showMovesCount,
      'adsRemoved': adsRemoved,
    };
  }

  /// Create from JSON for import
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 1.0,
      sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 1.0,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.6,
      sfxEnabled: json['sfxEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      themeType: ThemeType.values[json['themeType'] as int? ?? 0],
      particleEffects: json['particleEffects'] as bool? ?? true,
      animationsEnabled: json['animationsEnabled'] as bool? ?? true,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      brightness: Brightness.values[json['brightness'] as int? ?? 0],
      hintCooldownSeconds: json['hintCooldownSeconds'] as int? ?? 30,
      showTimer: json['showTimer'] as bool? ?? false,
      autoSave: json['autoSave'] as bool? ?? true,
      confirmUndo: json['confirmUndo'] as bool? ?? false,
      showMovesCount: json['showMovesCount'] as bool? ?? true,
      adsRemoved: json['adsRemoved'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'Settings(masterVolume: $masterVolume, sfxVolume: $sfxVolume, '
        'musicVolume: $musicVolume, sfxEnabled: $sfxEnabled, '
        'musicEnabled: $musicEnabled, hapticsEnabled: $hapticsEnabled, '
        'themeType: $themeType, particleEffects: $particleEffects, '
        'animationsEnabled: $animationsEnabled, reducedMotion: $reducedMotion, '
        'brightness: $brightness, hintCooldownSeconds: $hintCooldownSeconds, '
        'showTimer: $showTimer, autoSave: $autoSave, '
        'confirmUndo: $confirmUndo, showMovesCount: $showMovesCount, '
        'adsRemoved: $adsRemoved)';
  }
}

/// Provider for settings service
///
/// USAGE:
/// ```dart
/// // Access service
/// final service = ref.read(settingsServiceProvider);
/// await service.updateMasterVolume(0.5);
///
/// // Watch settings
/// final settings = ref.watch(settingsProvider);
/// ```
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final service = SettingsService();

  // Initialize on first access
  service.init();

  return service;
});

/// Provider for current settings (reactive)
///
/// This provider notifies listeners when settings change.
/// Use this in UI to reactively update based on settings.
final settingsProvider = Provider<Settings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.settings;
});
