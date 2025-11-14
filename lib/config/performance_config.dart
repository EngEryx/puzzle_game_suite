import 'dart:io';
import 'package:flutter/foundation.dart';

/// Performance configuration based on device capabilities
///
/// DEVICE TIERS:
/// - Low: Older devices, < 2GB RAM, older GPU
/// - Mid: Mid-range devices, 2-4GB RAM, decent GPU
/// - High: Flagship devices, 4GB+ RAM, high-end GPU
///
/// OPTIMIZATION STRATEGY:
/// - Detect device tier on app start
/// - Adjust quality settings accordingly
/// - Reduce animations/effects on low-end devices
/// - Maximize visual quality on high-end devices
///
/// USAGE:
/// ```dart
/// final config = PerformanceConfig.instance;
/// if (config.shouldEnableParticles) {
///   // Show particle effects
/// }
/// ```
class PerformanceConfig {
  static final PerformanceConfig instance = PerformanceConfig._();

  PerformanceConfig._() {
    _detectDeviceTier();
  }

  /// Current device tier
  DeviceTier _deviceTier = DeviceTier.mid;

  /// Get current device tier
  DeviceTier get deviceTier => _deviceTier;

  /// Manually set device tier (for testing)
  set deviceTier(DeviceTier tier) {
    _deviceTier = tier;
    if (kDebugMode) {
      print('[PerformanceConfig] Device tier set to: ${tier.name}');
    }
  }

  /// Detect device tier based on platform and capabilities
  void _detectDeviceTier() {
    // In debug mode, default to high for testing
    if (kDebugMode) {
      _deviceTier = DeviceTier.high;
      return;
    }

    // Platform-specific detection
    if (Platform.isAndroid) {
      _detectAndroidTier();
    } else if (Platform.isIOS) {
      _detectIOSTier();
    } else {
      // Desktop/Web defaults to high
      _deviceTier = DeviceTier.high;
    }

    if (kDebugMode) {
      print('[PerformanceConfig] Detected device tier: ${_deviceTier.name}');
    }
  }

  /// Detect Android device tier
  ///
  /// HEURISTICS:
  /// - Check Android version (older = lower tier)
  /// - Check available memory
  /// - Check processor cores
  void _detectAndroidTier() {
    // This is a simplified detection
    // In production, you might use device_info_plus package for detailed info

    // For now, use a conservative approach
    // Assume mid-tier by default for Android
    _deviceTier = DeviceTier.mid;

    // Could be enhanced with:
    // - device_info_plus for detailed specs
    // - Benchmark tests on first launch
    // - User preference override
  }

  /// Detect iOS device tier
  ///
  /// HEURISTICS:
  /// - iPhone 11+ = High tier
  /// - iPhone 8-10 = Mid tier
  /// - Older = Low tier
  void _detectIOSTier() {
    // This is a simplified detection
    // In production, you might use device_info_plus package

    // iOS devices generally perform well
    // Default to high tier for iOS
    _deviceTier = DeviceTier.high;

    // Could be enhanced with:
    // - device_info_plus for model detection
    // - iOS version check
    // - Metal performance tests
  }

  // QUALITY SETTINGS

  /// Animation complexity multiplier (0.0 to 1.0)
  double get animationComplexity {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 0.5; // Simplified animations
      case DeviceTier.mid:
        return 0.75; // Reduced complexity
      case DeviceTier.high:
        return 1.0; // Full complexity
    }
  }

  /// Animation duration multiplier
  double get animationDurationMultiplier {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 0.75; // Faster animations (less time = less frames)
      case DeviceTier.mid:
        return 0.9;
      case DeviceTier.high:
        return 1.0; // Full duration
    }
  }

  /// Whether to enable particle effects
  bool get shouldEnableParticles {
    return _deviceTier != DeviceTier.low;
  }

  /// Maximum particle count
  int get maxParticles {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 0; // No particles
      case DeviceTier.mid:
        return 20; // Limited particles
      case DeviceTier.high:
        return 50; // Full particle count
    }
  }

  /// Whether to enable blur effects
  bool get shouldEnableBlur {
    return _deviceTier == DeviceTier.high;
  }

  /// Shadow quality level (0-2)
  int get shadowQuality {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 0; // No shadows
      case DeviceTier.mid:
        return 1; // Simple shadows
      case DeviceTier.high:
        return 2; // Full shadows
    }
  }

  /// Whether to enable gradient backgrounds
  bool get shouldEnableGradients {
    return _deviceTier != DeviceTier.low;
  }

  /// Target frame rate
  int get targetFPS {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 30; // 30fps for low-end
      case DeviceTier.mid:
        return 60; // 60fps target
      case DeviceTier.high:
        return 60; // 60fps smooth
    }
  }

  /// Grid view cache extent (pixels to preload)
  double get gridViewCacheExtent {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 200.0; // Minimal preload
      case DeviceTier.mid:
        return 500.0; // Moderate preload
      case DeviceTier.high:
        return 1000.0; // Aggressive preload
    }
  }

  /// Whether to use RepaintBoundary aggressively
  bool get shouldUseRepaintBoundaries {
    return true; // Always use, it's a good practice
  }

  /// Level card entrance animation duration
  Duration get levelCardAnimationDuration {
    final baseDuration = const Duration(milliseconds: 400);
    return baseDuration * animationDurationMultiplier;
  }

  /// Pour animation duration
  Duration get pourAnimationDuration {
    final baseDuration = const Duration(milliseconds: 600);
    return baseDuration * animationDurationMultiplier;
  }

  /// Selection pulse animation duration
  Duration get selectionPulseDuration {
    final baseDuration = const Duration(milliseconds: 1000);
    return baseDuration * animationDurationMultiplier;
  }

  /// Whether to show performance overlay in debug mode
  bool get shouldShowPerformanceOverlay {
    return kDebugMode;
  }

  /// Maximum level cards to cache
  int get maxLevelCardCache {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 20;
      case DeviceTier.mid:
        return 50;
      case DeviceTier.high:
        return 100;
    }
  }

  /// Whether to enable level card entrance animations
  bool get shouldAnimateLevelCards {
    return _deviceTier != DeviceTier.low;
  }

  /// Stagger delay for level card animations (milliseconds)
  int get levelCardStaggerDelay {
    switch (_deviceTier) {
      case DeviceTier.low:
        return 0; // No stagger, all at once
      case DeviceTier.mid:
        return 30; // Moderate stagger
      case DeviceTier.high:
        return 50; // Full stagger effect
    }
  }

  /// Whether to use complex paint effects
  bool get shouldUseComplexPaints {
    return _deviceTier != DeviceTier.low;
  }

  /// Anti-aliasing quality
  bool get shouldUseAntiAliasing {
    return _deviceTier != DeviceTier.low;
  }

  /// Get quality settings summary
  QualitySettings get qualitySettings {
    return QualitySettings(
      animationComplexity: animationComplexity,
      particlesEnabled: shouldEnableParticles,
      maxParticles: maxParticles,
      blurEnabled: shouldEnableBlur,
      shadowQuality: shadowQuality,
      gradientsEnabled: shouldEnableGradients,
      targetFPS: targetFPS,
      antiAliasingEnabled: shouldUseAntiAliasing,
    );
  }

  /// Log current configuration
  void logConfiguration() {
    if (kDebugMode) {
      print('''
Performance Configuration
=========================
Device Tier: ${_deviceTier.name}
Target FPS: $targetFPS
Animation Complexity: ${(animationComplexity * 100).toStringAsFixed(0)}%
Particles: ${shouldEnableParticles ? 'Enabled (max: $maxParticles)' : 'Disabled'}
Blur Effects: ${shouldEnableBlur ? 'Enabled' : 'Disabled'}
Shadow Quality: $shadowQuality
Gradients: ${shouldEnableGradients ? 'Enabled' : 'Disabled'}
Cache Extent: ${gridViewCacheExtent}px
Level Card Cache: $maxLevelCardCache
Anti-aliasing: ${shouldUseAntiAliasing ? 'Enabled' : 'Disabled'}
''');
    }
  }
}

/// Device tier classification
enum DeviceTier {
  /// Low-end devices
  /// - Older phones (3+ years old)
  /// - < 2GB RAM
  /// - Weak GPU
  /// - Target: 30fps, minimal effects
  low,

  /// Mid-range devices
  /// - Modern budget/mid-range phones
  /// - 2-4GB RAM
  /// - Decent GPU
  /// - Target: 60fps, moderate effects
  mid,

  /// High-end devices
  /// - Flagship phones
  /// - 4GB+ RAM
  /// - High-end GPU
  /// - Target: 60fps, full effects
  high,
}

/// Quality settings data class
class QualitySettings {
  final double animationComplexity;
  final bool particlesEnabled;
  final int maxParticles;
  final bool blurEnabled;
  final int shadowQuality;
  final bool gradientsEnabled;
  final int targetFPS;
  final bool antiAliasingEnabled;

  const QualitySettings({
    required this.animationComplexity,
    required this.particlesEnabled,
    required this.maxParticles,
    required this.blurEnabled,
    required this.shadowQuality,
    required this.gradientsEnabled,
    required this.targetFPS,
    required this.antiAliasingEnabled,
  });

  @override
  String toString() {
    return 'QualitySettings('
        'animation: ${(animationComplexity * 100).toStringAsFixed(0)}%, '
        'particles: $particlesEnabled, '
        'blur: $blurEnabled, '
        'shadows: $shadowQuality, '
        'target: ${targetFPS}fps)';
  }
}

/// Performance preset configurations
class PerformancePresets {
  /// Preset for battery saving mode
  static const QualitySettings batterySaver = QualitySettings(
    animationComplexity: 0.5,
    particlesEnabled: false,
    maxParticles: 0,
    blurEnabled: false,
    shadowQuality: 0,
    gradientsEnabled: false,
    targetFPS: 30,
    antiAliasingEnabled: false,
  );

  /// Preset for balanced performance
  static const QualitySettings balanced = QualitySettings(
    animationComplexity: 0.75,
    particlesEnabled: true,
    maxParticles: 20,
    blurEnabled: false,
    shadowQuality: 1,
    gradientsEnabled: true,
    targetFPS: 60,
    antiAliasingEnabled: true,
  );

  /// Preset for maximum quality
  static const QualitySettings maxQuality = QualitySettings(
    animationComplexity: 1.0,
    particlesEnabled: true,
    maxParticles: 50,
    blurEnabled: true,
    shadowQuality: 2,
    gradientsEnabled: true,
    targetFPS: 60,
    antiAliasingEnabled: true,
  );
}
