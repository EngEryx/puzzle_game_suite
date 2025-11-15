import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/game_theme.dart';
import '../../../core/services/settings_service.dart';

/// Settings controller state
///
/// Manages the current settings state and provides update methods.
/// Uses StateNotifier for reactive updates with Riverpod.
class SettingsController extends StateNotifier<Settings> {
  final SettingsService _service;

  SettingsController(this._service) : super(_service.settings);

  /// Refresh state from service
  ///
  /// Call this after service initialization or external updates
  void refresh() {
    state = _service.settings;
  }

  // ==================== AUDIO SETTINGS ====================

  /// Update master volume with haptic feedback
  Future<void> updateMasterVolume(double volume) async {
    await _service.updateMasterVolume(volume);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Update SFX volume with haptic feedback
  Future<void> updateSfxVolume(double volume) async {
    await _service.updateSfxVolume(volume);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Update music volume with haptic feedback
  Future<void> updateMusicVolume(double volume) async {
    await _service.updateMusicVolume(volume);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle SFX with haptic feedback
  Future<void> toggleSfx() async {
    await _service.updateSfxEnabled(!state.sfxEnabled);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle music with haptic feedback
  Future<void> toggleMusic() async {
    await _service.updateMusicEnabled(!state.musicEnabled);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle haptics
  Future<void> toggleHaptics() async {
    await _service.updateHapticsEnabled(!state.hapticsEnabled);
    state = _service.settings;
    // Don't provide haptic feedback for haptic toggle
    // (would be confusing if user is trying to disable it)
  }

  // ==================== VISUAL SETTINGS ====================

  /// Update theme type with haptic feedback
  Future<void> updateThemeType(ThemeType theme) async {
    await _service.updateThemeType(theme);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle particle effects with haptic feedback
  Future<void> toggleParticleEffects() async {
    await _service.updateParticleEffects(!state.particleEffects);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle animations with haptic feedback
  Future<void> toggleAnimations() async {
    await _service.updateAnimationsEnabled(!state.animationsEnabled);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle reduced motion with haptic feedback
  Future<void> toggleReducedMotion() async {
    await _service.updateReducedMotion(!state.reducedMotion);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Update brightness with haptic feedback
  Future<void> updateBrightness(Brightness brightness) async {
    await _service.updateBrightness(brightness);
    state = _service.settings;
    _hapticFeedback();
  }

  // ==================== GAMEPLAY SETTINGS ====================

  /// Update hint cooldown with validation and haptic feedback
  Future<void> updateHintCooldown(int seconds) async {
    // Validate: 10 to 300 seconds (10s to 5min)
    final clamped = seconds.clamp(10, 300);
    await _service.updateHintCooldown(clamped);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle timer display with haptic feedback
  Future<void> toggleShowTimer() async {
    await _service.updateShowTimer(!state.showTimer);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle auto save with haptic feedback
  Future<void> toggleAutoSave() async {
    await _service.updateAutoSave(!state.autoSave);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle confirm undo with haptic feedback
  Future<void> toggleConfirmUndo() async {
    await _service.updateConfirmUndo(!state.confirmUndo);
    state = _service.settings;
    _hapticFeedback();
  }

  /// Toggle moves count display with haptic feedback
  Future<void> toggleShowMovesCount() async {
    await _service.updateShowMovesCount(!state.showMovesCount);
    state = _service.settings;
    _hapticFeedback();
  }

  // ==================== BULK OPERATIONS ====================

  /// Reset all settings to defaults
  ///
  /// Returns true if user confirmed the reset
  Future<bool> resetToDefaults() async {
    await _service.resetToDefaults();
    state = _service.settings;
    _hapticFeedback();
    return true;
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return _service.exportSettings();
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> json) async {
    await _service.importSettings(json);
    state = _service.settings;
    _hapticFeedback();
  }

  // ==================== HELPERS ====================

  /// Provide haptic feedback if enabled
  void _hapticFeedback() {
    if (state.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }
}

/// Provider for settings controller
///
/// This is the main provider to use in UI for settings management.
///
/// USAGE:
/// ```dart
/// // Read controller
/// final controller = ref.read(settingsControllerProvider.notifier);
/// await controller.updateMasterVolume(0.5);
///
/// // Watch state
/// final settings = ref.watch(settingsControllerProvider);
/// ```
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, Settings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsController(service);
});

/// Provider for specific settings (optimization - prevents full rebuild)

/// Master volume provider
final masterVolumeProvider = Provider<double>((ref) {
  return ref.watch(settingsControllerProvider).masterVolume;
});

/// SFX volume provider
final sfxVolumeProvider = Provider<double>((ref) {
  return ref.watch(settingsControllerProvider).sfxVolume;
});

/// Music volume provider
final musicVolumeProvider = Provider<double>((ref) {
  return ref.watch(settingsControllerProvider).musicVolume;
});

/// SFX enabled provider
final sfxEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).sfxEnabled;
});

/// Music enabled provider
final musicEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).musicEnabled;
});

/// Haptics enabled provider
final hapticsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).hapticsEnabled;
});

/// Theme type provider
final themeTypeProvider = Provider<ThemeType>((ref) {
  return ref.watch(settingsControllerProvider).themeType;
});

/// Particle effects provider
final particleEffectsProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).particleEffects;
});

/// Animations enabled provider
final animationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).animationsEnabled;
});

/// Reduced motion provider
final reducedMotionProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).reducedMotion;
});

/// Brightness provider
final brightnessProvider = Provider<Brightness>((ref) {
  return ref.watch(settingsControllerProvider).brightness;
});

/// Hint cooldown provider
final hintCooldownProvider = Provider<int>((ref) {
  return ref.watch(settingsControllerProvider).hintCooldownSeconds;
});

/// Show timer provider
final showTimerProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).showTimer;
});

/// Auto save provider
final autoSaveProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).autoSave;
});

/// Confirm undo provider
final confirmUndoProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).confirmUndo;
});

/// Show moves count provider
final showMovesCountProvider = Provider<bool>((ref) {
  return ref.watch(settingsControllerProvider).showMovesCount;
});
