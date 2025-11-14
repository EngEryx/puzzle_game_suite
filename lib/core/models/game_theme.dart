import 'package:flutter/material.dart';
import 'game_color.dart';

/// Theme type enumeration for the 4 game variations.
///
/// Each theme represents a distinct visual and gameplay experience:
/// - water: Liquid sorting with translucent water effects
/// - nutsBolts: Mechanical sorting with metallic bolts
/// - balls: Physical sorting with bouncing spheres
/// - testTubes: Scientific sorting with chemical liquids
enum ThemeType {
  water,
  nutsBolts,
  balls,
  testTubes;

  /// Display name for UI
  String get displayName {
    return switch (this) {
      ThemeType.water => 'Water Sort',
      ThemeType.nutsBolts => 'Nuts & Bolts',
      ThemeType.balls => 'Ball Sort',
      ThemeType.testTubes => 'Test Tubes',
    };
  }

  /// Short description for theme selection
  String get description {
    return switch (this) {
      ThemeType.water => 'Sort colorful liquids in transparent containers',
      ThemeType.nutsBolts => 'Organize colorful bolts in mechanical holders',
      ThemeType.balls => 'Stack bouncing balls in tubes',
      ThemeType.testTubes => 'Mix chemical solutions in laboratory tubes',
    };
  }

  /// Icon for theme selection UI
  IconData get icon {
    return switch (this) {
      ThemeType.water => Icons.water_drop,
      ThemeType.nutsBolts => Icons.settings,
      ThemeType.balls => Icons.sports_baseball,
      ThemeType.testTubes => Icons.science,
    };
  }
}

/// Abstract base class for game themes.
///
/// DESIGN PATTERN: Strategy Pattern
///
/// Each theme is a strategy that defines how to:
/// 1. Render containers and game elements
/// 2. Map colors to visual representations
/// 3. Define background and atmospheric effects
/// 4. Reference appropriate sound effects
/// 5. Configure particle effects for animations
///
/// WHY ABSTRACT CLASS VS INTERFACE?
/// - Allows default implementations for common behavior
/// - Provides shared helper methods
/// - Enforces contract while reducing boilerplate
/// - Better code reuse than pure interface
///
/// PERFORMANCE CONSIDERATIONS:
/// - Theme instances should be singletons (created once)
/// - Color palettes should be precomputed and cached
/// - Gradients should be lazy-loaded and cached
/// - Avoid allocations in rendering hot paths
///
/// EXTENSIBILITY:
/// Adding a new theme requires:
/// 1. Create new ThemeType enum value
/// 2. Implement GameTheme abstract class
/// 3. Add to ThemeRegistry
/// 4. Add assets (sounds, images) if needed
///
abstract class GameTheme {
  /// Unique identifier for this theme
  ThemeType get type;

  /// Display name for UI
  String get name => type.displayName;

  /// Theme description for selection screen
  String get description => type.description;

  /// Theme icon for UI
  IconData get icon => type.icon;

  // ============================================================================
  // VISUAL STYLE CONFIGURATION
  // ============================================================================

  /// Container shape style.
  ///
  /// Defines the visual appearance of the container:
  /// - Border radius
  /// - Edge style (rounded, sharp, custom)
  /// - Container proportions
  ///
  /// CUSTOMIZATION POINTS:
  /// - Water: Rounded, flowing shape
  /// - Nuts & Bolts: Sharp, mechanical edges
  /// - Balls: Cylindrical tube
  /// - Test Tubes: Scientific test tube shape
  ContainerShape get containerShape;

  /// Color rendering style.
  ///
  /// Defines how game colors are visually represented:
  /// - Opacity (translucent vs solid)
  /// - Gradient style
  /// - Specular highlights
  /// - Material properties
  ///
  /// PERFORMANCE NOTE:
  /// Color calculations should be cached, not computed per frame.
  ColorStyle get colorStyle;

  /// Background gradient for the game screen.
  ///
  /// Creates atmospheric context for the theme.
  /// Returns null for simple solid color backgrounds.
  ///
  /// EXAMPLES:
  /// - Water: Ocean blue gradient
  /// - Nuts & Bolts: Workshop grey gradient
  /// - Balls: Playground gradient
  /// - Test Tubes: Laboratory white gradient
  Gradient? get backgroundGradient;

  /// Background color if no gradient is used
  Color get backgroundColor => const Color(0xFFF5F5F5);

  // ============================================================================
  // COLOR MAPPING
  // ============================================================================

  /// Get the visual color for a game color.
  ///
  /// This is the core color mapping method. Each theme interprets
  /// game colors differently based on its visual style.
  ///
  /// PARAMETERS:
  /// - [gameColor]: The logical game color
  ///
  /// RETURNS:
  /// - Flutter Color with theme-specific properties (opacity, tone, etc.)
  ///
  /// EXAMPLES:
  /// - Water theme: Returns translucent version (opacity 0.7)
  /// - Nuts & Bolts: Returns metallic version (higher saturation)
  /// - Balls: Returns solid bright version (full opacity)
  /// - Test Tubes: Returns chemical liquid version (slight translucency)
  ///
  /// PERFORMANCE:
  /// This method is called frequently during rendering.
  /// Implementations should cache color values.
  Color getColorForGameColor(GameColor gameColor);

  /// Get the complete color palette for this theme.
  ///
  /// Returns a map of all game colors to their theme-specific representations.
  /// This allows batch processing and caching of all colors.
  ///
  /// DEFAULT IMPLEMENTATION:
  /// Iterates through all GameColors and calls [getColorForGameColor].
  /// Themes can override for performance optimization.
  Map<GameColor, Color> getColorPalette() {
    return {
      for (final gameColor in GameColor.values)
        gameColor: getColorForGameColor(gameColor),
    };
  }

  /// Get gradient for a color segment.
  ///
  /// Creates a gradient appropriate for this theme's visual style.
  /// Used for rendering 3D depth in color segments.
  ///
  /// PARAMETERS:
  /// - [gameColor]: The game color to create gradient for
  ///
  /// RETURNS:
  /// - LinearGradient with theme-specific shading
  ///
  /// CUSTOMIZATION:
  /// - Water: Subtle gradient for translucent liquid
  /// - Nuts & Bolts: Strong metallic gradient
  /// - Balls: Spherical gradient simulation
  /// - Test Tubes: Chemical liquid gradient
  LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    final lighter = Color.lerp(baseColor, Colors.white, 0.3)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.3)!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lighter, baseColor, darker],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // CONTAINER APPEARANCE
  // ============================================================================

  /// Container outline color.
  ///
  /// The border/edge color of the container.
  /// Should have good contrast with background.
  Color get containerOutlineColor => const Color(0xFF37474F);

  /// Container outline width in pixels.
  double get containerOutlineWidth => 3.0;

  /// Container background color (empty space inside).
  ///
  /// The color visible when container is empty or partially filled.
  Color get containerBackgroundColor => const Color(0xFFECEFF1);

  /// Container shadow configuration.
  ///
  /// Defines the shadow cast by the container for depth perception.
  /// Returns null to disable shadows.
  List<BoxShadow>? get containerShadows => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(2, 2),
        ),
      ];

  /// Border radius for container corners.
  double get containerBorderRadius => 12.0;

  // ============================================================================
  // ANIMATION & EFFECTS
  // ============================================================================

  /// Get particle effects configuration for this theme.
  ///
  /// Defines particles emitted during pour animations.
  ///
  /// EXAMPLES:
  /// - Water: Droplet particles
  /// - Nuts & Bolts: Metal spark particles
  /// - Balls: Bounce particles
  /// - Test Tubes: Bubble particles
  ///
  /// Returns null to disable particle effects.
  ParticleConfig? getParticleConfig() => null;

  /// Animation duration multiplier.
  ///
  /// Scales the base animation duration to match theme feel.
  ///
  /// EXAMPLES:
  /// - Water: 1.0 (normal liquid flow)
  /// - Nuts & Bolts: 0.8 (faster, mechanical)
  /// - Balls: 1.2 (slower, bouncy)
  /// - Test Tubes: 1.0 (normal chemical pour)
  double get animationSpeedMultiplier => 1.0;

  /// Whether to show ripple effects during pour.
  bool get showRippleEffects => true;

  /// Whether to show splash effects on landing.
  bool get showSplashEffects => true;

  // ============================================================================
  // AUDIO
  // ============================================================================

  /// Sound effect path for pour action.
  ///
  /// AUDIO PHILOSOPHY:
  /// Each theme has its own sound profile that matches the visual style:
  /// - Water: Liquid pouring sounds
  /// - Nuts & Bolts: Metallic clink sounds
  /// - Balls: Bouncing sounds
  /// - Test Tubes: Bubbling chemical sounds
  ///
  /// ASSET STRUCTURE:
  /// assets/sounds/{theme}/pour.mp3
  ///
  /// Returns null to use default sound or disable sound.
  String? get pourSoundPath => null;

  /// Sound effect path for container selection.
  String? get selectSoundPath => null;

  /// Sound effect path for successful level completion.
  String? get winSoundPath => null;

  /// Sound effect path for invalid move.
  String? get invalidMoveSoundPath => null;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if this theme uses translucent colors.
  ///
  /// Affects rendering optimization decisions.
  bool get usesTranslucency => colorStyle == ColorStyle.translucent;

  /// Check if this theme uses particle effects.
  bool get usesParticles => getParticleConfig() != null;

  /// Get debug information about this theme.
  String get debugInfo {
    return '''
Theme Debug Info:
  Type: $type
  Name: $name
  Container Shape: $containerShape
  Color Style: $colorStyle
  Uses Translucency: $usesTranslucency
  Uses Particles: $usesParticles
  Animation Speed: ${animationSpeedMultiplier}x
  Ripple Effects: $showRippleEffects
  Splash Effects: $showSplashEffects
    ''';
  }

  @override
  String toString() => 'GameTheme($name)';
}

// ==============================================================================
// SUPPORTING TYPES
// ==============================================================================

/// Container shape configuration.
///
/// Defines the geometric properties of the container.
enum ContainerShape {
  /// Rounded rectangular container (water, general purpose)
  rounded,

  /// Sharp rectangular container (nuts & bolts, mechanical)
  rectangular,

  /// Cylindrical container (balls, test tubes)
  cylindrical,

  /// Custom path-based shape
  custom;
}

/// Color rendering style.
///
/// Defines how colors are visually represented.
enum ColorStyle {
  /// Translucent colors with see-through effect (water theme)
  translucent,

  /// Solid opaque colors (nuts & bolts, balls)
  solid,

  /// Metallic reflective colors (nuts & bolts)
  metallic,

  /// Glossy shiny colors (balls)
  glossy,

  /// Matte flat colors
  matte;
}

/// Particle effect configuration.
///
/// Defines particle system properties for animations.
class ParticleConfig {
  /// Number of particles to emit per pour action
  final int particleCount;

  /// Particle size in pixels
  final double particleSize;

  /// Particle lifetime in milliseconds
  final int lifetimeMs;

  /// Particle color (null = use pour color)
  final Color? particleColor;

  /// Particle emission pattern
  final ParticlePattern pattern;

  const ParticleConfig({
    this.particleCount = 10,
    this.particleSize = 4.0,
    this.lifetimeMs = 500,
    this.particleColor,
    this.pattern = ParticlePattern.spray,
  });

  /// Preset for water droplets
  static const ParticleConfig waterDroplets = ParticleConfig(
    particleCount: 8,
    particleSize: 3.0,
    lifetimeMs: 400,
    pattern: ParticlePattern.spray,
  );

  /// Preset for metal sparks
  static const ParticleConfig metalSparks = ParticleConfig(
    particleCount: 12,
    particleSize: 2.0,
    lifetimeMs: 300,
    particleColor: Color(0xFFFFD700), // Gold sparks
    pattern: ParticlePattern.burst,
  );

  /// Preset for bubbles
  static const ParticleConfig bubbles = ParticleConfig(
    particleCount: 6,
    particleSize: 5.0,
    lifetimeMs: 600,
    pattern: ParticlePattern.rise,
  );
}

/// Particle emission pattern.
enum ParticlePattern {
  /// Spray outward in cone
  spray,

  /// Burst in all directions
  burst,

  /// Rise upward
  rise,

  /// Fall downward
  fall;
}
