import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/game_color.dart';
import '../../../core/models/game_theme.dart';
import '../../../shared/constants/game_colors.dart';

/// Water sorting theme implementation.
///
/// VISUAL STYLE:
/// - Translucent liquid colors with wave effects
/// - Flowing water-like appearance
/// - Ocean/water background gradient
/// - Gentle ripple and splash effects
///
/// DESIGN PHILOSOPHY:
/// This is the classic water sorting puzzle experience with:
/// - Realistic liquid rendering
/// - Translucent colors that blend naturally
/// - Water physics-inspired animations
/// - Calming ocean aesthetics
///
/// PERFORMANCE:
/// - Lazy-loads color palette (computed once)
/// - Caches gradient definitions
/// - Minimal per-frame allocations
/// - Optimized for 60fps rendering
///
class WaterTheme extends GameTheme {
  /// Singleton instance
  static final WaterTheme _instance = WaterTheme._internal();

  /// Factory constructor returns singleton
  factory WaterTheme() => _instance;

  /// Private constructor for singleton
  WaterTheme._internal();

  /// Cached color palette (lazy-loaded)
  Map<GameColor, Color>? _cachedPalette;

  @override
  ThemeType get type => ThemeType.water;

  // ============================================================================
  // VISUAL STYLE
  // ============================================================================

  @override
  ContainerShape get containerShape => ContainerShape.rounded;

  @override
  ColorStyle get colorStyle => ColorStyle.translucent;

  @override
  Gradient get backgroundGradient {
    // Ocean-inspired gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF89CFF0), // Sky blue (top)
        Color(0xFF4A90E2), // Ocean blue (middle)
        Color(0xFF2E5C8A), // Deep ocean blue (bottom)
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // COLOR MAPPING
  // ============================================================================

  @override
  Color getColorForGameColor(GameColor gameColor) {
    // Water theme uses translucent colors (70% opacity)
    // This creates the realistic liquid appearance
    final baseColor = GameColors.getColor(gameColor);
    return baseColor.withOpacity(0.7);
  }

  @override
  Map<GameColor, Color> getColorPalette() {
    // Use cached palette if available
    _cachedPalette ??= {
      // Translucent liquid colors
      GameColor.red: const Color(0xFFE74C3C).withOpacity(0.7),
      GameColor.blue: const Color(0xFF3498DB).withOpacity(0.7),
      GameColor.yellow: const Color(0xFFF1C40F).withOpacity(0.7),
      GameColor.green: const Color(0xFF2ECC71).withOpacity(0.7),
      GameColor.purple: const Color(0xFF9B59B6).withOpacity(0.7),
      GameColor.orange: const Color(0xFFE67E22).withOpacity(0.7),
      GameColor.pink: const Color(0xFFE91E63).withOpacity(0.7),
      GameColor.cyan: const Color(0xFF00BCD4).withOpacity(0.7),
      GameColor.brown: const Color(0xFF8D6E63).withOpacity(0.7),
      GameColor.lime: const Color(0xFF9CCC65).withOpacity(0.7),
      GameColor.magenta: const Color(0xFFAB47BC).withOpacity(0.7),
      GameColor.teal: const Color(0xFF009688).withOpacity(0.7),
    };
    return _cachedPalette!;
  }

  @override
  LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);

    // Water has subtle gradients for realistic liquid depth
    final lighter = Color.lerp(baseColor, Colors.white, 0.25)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.25)!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lighter.withOpacity(0.8), // Top surface (lighter, more translucent)
        baseColor, // Middle
        darker.withOpacity(0.9), // Bottom (darker, less translucent)
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // CONTAINER APPEARANCE
  // ============================================================================

  @override
  Color get containerOutlineColor => const Color(0xFF4A90E2); // Water blue

  @override
  double get containerOutlineWidth => 3.0;

  @override
  Color get containerBackgroundColor {
    // Very light blue tint for water container interior
    return const Color(0xFFE3F2FD);
  }

  @override
  List<BoxShadow> get containerShadows => [
        // Soft shadow for floating container effect
        BoxShadow(
          color: Colors.blue.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
        // Ambient shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  double get containerBorderRadius => 12.0;

  // ============================================================================
  // ANIMATION & EFFECTS
  // ============================================================================

  @override
  ParticleConfig getParticleConfig() {
    // Water droplet particles
    return ParticleConfig.waterDroplets;
  }

  @override
  double get animationSpeedMultiplier => 1.0; // Normal water flow speed

  @override
  bool get showRippleEffects => true; // Water shows ripples

  @override
  bool get showSplashEffects => true; // Water splashes on impact

  // ============================================================================
  // AUDIO
  // ============================================================================

  @override
  String? get pourSoundPath => 'assets/sounds/water/pour.mp3';

  @override
  String? get selectSoundPath => 'assets/sounds/water/select.mp3';

  @override
  String? get winSoundPath => 'assets/sounds/water/win.mp3';

  @override
  String? get invalidMoveSoundPath => 'assets/sounds/water/invalid.mp3';

  // ============================================================================
  // WATER-SPECIFIC FEATURES
  // ============================================================================

  /// Wave amplitude for water surface effects.
  ///
  /// Used when rendering the top surface of liquid in containers.
  double get waveAmplitude => 2.0;

  /// Wave frequency for surface ripples.
  double get waveFrequency => 0.5;

  /// Whether to render wave effects on liquid surface.
  bool get renderWaves => true;

  /// Opacity for wave effects.
  double get waveOpacity => 0.3;

  /// Color for wave highlights.
  Color get waveHighlightColor => Colors.white.withOpacity(0.4);

  /// Create wave path for rendering liquid surface.
  ///
  /// USAGE:
  /// This can be used by custom painters to draw realistic water surfaces.
  ///
  /// PARAMETERS:
  /// - [rect]: The rectangle area to draw wave in
  /// - [progress]: Animation progress for wave motion (0.0 to 1.0)
  ///
  /// RETURNS:
  /// - Path representing the wave curve
  Path createWavePath(Rect rect, double progress) {
    final path = Path();
    final startX = rect.left;
    final baseY = rect.top;
    final width = rect.width;

    path.moveTo(startX, baseY);

    // Create sine wave using multiple points
    const pointCount = 20;
    for (int i = 0; i <= pointCount; i++) {
      final x = startX + (width * i / pointCount);

      // Sine wave calculation with animation
      final normalizedX = i / pointCount;
      final animatedPhase = progress * 2 * math.pi; // Full rotation over progress
      final y = baseY +
          waveAmplitude *
              math.sin(normalizedX * waveFrequency * 2 * math.pi + animatedPhase);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  /// Get reflection color for water effects.
  ///
  /// Used for rendering light reflections on liquid surfaces.
  Color getReflectionColor(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    return Color.lerp(baseColor, Colors.white, 0.5)!.withOpacity(0.3);
  }

  /// Get refraction color for underwater effects.
  ///
  /// Simulates light refraction through water.
  Color getRefractionColor(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    return Color.lerp(baseColor, const Color(0xFF4A90E2), 0.2)!;
  }
}

// ==============================================================================
// WATER THEME EXTENSIONS
// ==============================================================================

/// Extension methods for water-specific rendering helpers.
extension WaterThemeExtensions on WaterTheme {
  /// Get water-specific gradient with wave highlights.
  LinearGradient getWaterGradientWithWaves(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    final lighter = Color.lerp(baseColor, Colors.white, 0.3)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.2)!;

    return LinearGradient(
      begin: Alignment.topLeft, // Angled for wave effect
      end: Alignment.bottomRight,
      colors: [
        lighter.withOpacity(0.85), // Top surface with waves
        baseColor.withOpacity(0.75), // Middle layer
        baseColor.withOpacity(0.7), // Middle-bottom layer
        darker.withOpacity(0.8), // Bottom depth
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Check if a color should render with enhanced translucency.
  ///
  /// Some colors (like cyan, blue) look better with more translucency
  /// in water theme to simulate actual water.
  bool shouldUseEnhancedTranslucency(GameColor gameColor) {
    return gameColor == GameColor.cyan ||
        gameColor == GameColor.blue ||
        gameColor == GameColor.teal;
  }

  /// Get opacity for a specific game color in water theme.
  double getOpacityForColor(GameColor gameColor) {
    if (shouldUseEnhancedTranslucency(gameColor)) {
      return 0.6; // More translucent for water-like colors
    }
    return 0.7; // Standard translucency
  }
}
