import 'package:flutter/material.dart';
import '../../../core/models/game_color.dart';
import '../../../core/models/game_theme.dart';
import '../../../shared/constants/game_colors.dart';

/// Ball sorting theme implementation.
///
/// VISUAL STYLE:
/// - Solid glossy spherical balls
/// - Bouncy playful appearance
/// - Playground/sports background aesthetic
/// - Vibrant bright colors with shine
///
/// DESIGN PHILOSOPHY:
/// This theme transforms the puzzle into a ball sorting game:
/// - Spherical elements instead of liquid
/// - Glossy plastic/rubber ball appearance
/// - Bouncy physics feel in animations
/// - Fun playground atmosphere
///
/// GAMEPLAY VARIATION:
/// The visual representation of stacking colorful balls creates
/// a playful, casual game feel compared to the scientific liquid sorting.
///
/// PERFORMANCE:
/// - Glossy gradients (radial for sphere effect)
/// - Bounce animation curves
/// - Optimized for 60fps with smooth physics
///
class BallTheme extends GameTheme {
  /// Singleton instance
  static final BallTheme _instance = BallTheme._internal();

  /// Factory constructor returns singleton
  factory BallTheme() => _instance;

  /// Private constructor for singleton
  BallTheme._internal();

  /// Cached color palette (lazy-loaded)
  Map<GameColor, Color>? _cachedPalette;

  @override
  ThemeType get type => ThemeType.balls;

  // ============================================================================
  // VISUAL STYLE
  // ============================================================================

  @override
  ContainerShape get containerShape => ContainerShape.cylindrical;

  @override
  ColorStyle get colorStyle => ColorStyle.glossy;

  @override
  Gradient get backgroundGradient {
    // Playground/sports gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFEB3B), // Sunny yellow (top)
        Color(0xFFFDD835), // Bright yellow (middle)
        Color(0xFF81C784), // Grass green (bottom)
      ],
      stops: [0.0, 0.4, 1.0],
    );
  }

  // ============================================================================
  // COLOR MAPPING
  // ============================================================================

  @override
  Color getColorForGameColor(GameColor gameColor) {
    // Ball theme uses bright, vibrant solid colors
    // Enhanced saturation and brightness for playful feel
    final baseColor = GameColors.getColor(gameColor);

    // Increase saturation and brightness for vibrant ball colors
    final hslColor = HSLColor.fromColor(baseColor);
    final brightColor = hslColor
        .withSaturation((hslColor.saturation * 1.1).clamp(0.0, 1.0))
        .withLightness((hslColor.lightness * 1.1).clamp(0.0, 1.0))
        .toColor();

    return brightColor; // Full opacity - solid balls
  }

  @override
  Map<GameColor, Color> getColorPalette() {
    // Use cached palette if available
    _cachedPalette ??= {
      // Bright glossy ball colors
      GameColor.red: const Color(0xFFF44336), // Bright red
      GameColor.blue: const Color(0xFF2196F3), // Bright blue
      GameColor.yellow: const Color(0xFFFFEB3B), // Bright yellow
      GameColor.green: const Color(0xFF4CAF50), // Bright green
      GameColor.purple: const Color(0xFF9C27B0), // Bright purple
      GameColor.orange: const Color(0xFFFF9800), // Bright orange
      GameColor.pink: const Color(0xFFE91E63), // Bright pink
      GameColor.cyan: const Color(0xFF00BCD4), // Bright cyan
      GameColor.brown: const Color(0xFF8D6E63), // Warm brown
      GameColor.lime: const Color(0xFFCDDC39), // Bright lime
      GameColor.magenta: const Color(0xFFE91E63), // Bright magenta
      GameColor.teal: const Color(0xFF009688), // Bright teal
    };
    return _cachedPalette!;
  }

  @override
  LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);

    // Glossy spherical gradient
    // Creates the appearance of a 3D ball with specular highlight
    final highlight = Color.lerp(baseColor, Colors.white, 0.6)!;
    final shine = Color.lerp(baseColor, Colors.white, 0.4)!;
    final shadow = Color.lerp(baseColor, Colors.black, 0.3)!;

    return LinearGradient(
      begin: Alignment.topLeft, // Light source from top-left
      end: Alignment.bottomRight,
      colors: [
        highlight, // Top-left specular highlight
        shine, // Upper shine
        baseColor, // Middle true color
        baseColor, // Lower middle
        shadow, // Bottom-right shadow
      ],
      stops: const [0.0, 0.2, 0.5, 0.7, 1.0],
    );
  }

  /// Get radial gradient for spherical ball appearance.
  ///
  /// This creates a more realistic sphere effect than linear gradients.
  RadialGradient getSphericalGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    final highlight = Color.lerp(baseColor, Colors.white, 0.7)!;
    final shadow = Color.lerp(baseColor, Colors.black, 0.4)!;

    return RadialGradient(
      center: const Alignment(-0.3, -0.3), // Offset highlight
      radius: 1.2,
      colors: [
        highlight, // Center highlight
        baseColor, // Mid color
        baseColor, // True color
        shadow, // Edge shadow
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
  }

  // ============================================================================
  // CONTAINER APPEARANCE
  // ============================================================================

  @override
  Color get containerOutlineColor => const Color(0xFF616161); // Dark grey tube

  @override
  double get containerOutlineWidth => 3.5;

  @override
  Color get containerBackgroundColor {
    // Clear/white tube interior
    return const Color(0xFFFAFAFA);
  }

  @override
  List<BoxShadow> get containerShadows => [
        // Light shadow for floating tube effect
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
      ];

  @override
  double get containerBorderRadius => 20.0; // More rounded for tube feel

  // ============================================================================
  // ANIMATION & EFFECTS
  // ============================================================================

  @override
  ParticleConfig? getParticleConfig() {
    // No particles for balls (they're solid objects)
    return null;
  }

  @override
  double get animationSpeedMultiplier => 1.2; // Slower for bouncy feel

  @override
  bool get showRippleEffects => false; // No ripples for solid balls

  @override
  bool get showSplashEffects => true; // Bounce effect instead of splash

  // ============================================================================
  // AUDIO
  // ============================================================================

  @override
  String? get pourSoundPath => 'assets/sounds/balls/pour.mp3'; // Ball dropping

  @override
  String? get selectSoundPath => 'assets/sounds/balls/select.mp3'; // Ball tap

  @override
  String? get winSoundPath => 'assets/sounds/balls/win.mp3'; // Victory chime

  @override
  String? get invalidMoveSoundPath => 'assets/sounds/balls/invalid.mp3'; // Bonk sound

  // ============================================================================
  // BALL-SPECIFIC FEATURES
  // ============================================================================

  /// Whether to render balls as spheres vs circles.
  bool get render3DBalls => true;

  /// Ball size as percentage of segment height.
  ///
  /// Balls should be slightly smaller than segment to show spacing.
  double get ballSizeRatio => 0.85;

  /// Spacing between stacked balls.
  double get ballSpacing => 2.0;

  /// Specular highlight size (0.0 to 1.0).
  double get highlightSize => 0.25;

  /// Specular highlight intensity (0.0 to 1.0).
  double get highlightIntensity => 0.8;

  /// Specular highlight position offset.
  Offset get highlightOffset => const Offset(-0.25, -0.25);

  /// Shadow opacity under balls.
  double get ballShadowOpacity => 0.2;

  /// Shadow blur radius.
  double get ballShadowBlur => 4.0;

  /// Bounce animation curve.
  ///
  /// Used for pour animations to create realistic ball bouncing.
  Curve get bounceCurve => Curves.bounceOut;

  /// Bounce height multiplier.
  ///
  /// How high balls bounce on landing (1.0 = normal, 2.0 = double height).
  double get bounceHeightMultiplier => 1.5;

  /// Number of bounces.
  int get bounceCount => 2;

  /// Get bounce height for a specific bounce number.
  ///
  /// PARAMETERS:
  /// - [bounceNumber]: Which bounce (0 = first, 1 = second, etc.)
  ///
  /// RETURNS:
  /// - Height multiplier for this bounce
  double getBounceHeight(int bounceNumber) {
    if (bounceNumber >= bounceCount) return 0.0;

    // Each bounce is progressively smaller
    final ratio = 1.0 - (bounceNumber / bounceCount);
    return bounceHeightMultiplier * ratio * ratio;
  }

  /// Create ball shape path.
  ///
  /// USAGE:
  /// Custom painters can use this to draw circular balls.
  ///
  /// PARAMETERS:
  /// - [center]: Center point of the ball
  /// - [radius]: Ball radius
  ///
  /// RETURNS:
  /// - Path representing the ball circle
  Path createBallPath(Offset center, double radius) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  /// Get ball position in segment.
  ///
  /// Balls are centered in their segments with spacing.
  Offset getBallCenter(Rect segmentRect) {
    return Offset(
      segmentRect.center.dx,
      segmentRect.center.dy,
    );
  }

  /// Get ball radius for a segment.
  double getBallRadius(Rect segmentRect) {
    final maxRadius = segmentRect.height * ballSizeRatio / 2;
    final maxWidth = segmentRect.width * ballSizeRatio / 2;
    return maxRadius < maxWidth ? maxRadius : maxWidth;
  }

  /// Get shine position for ball highlight.
  ///
  /// PARAMETERS:
  /// - [ballCenter]: Center of the ball
  /// - [ballRadius]: Radius of the ball
  ///
  /// RETURNS:
  /// - Position of the specular highlight
  Offset getShinePosition(Offset ballCenter, double ballRadius) {
    return Offset(
      ballCenter.dx + (ballRadius * highlightOffset.dx),
      ballCenter.dy + (ballRadius * highlightOffset.dy),
    );
  }

  /// Get shadow position under ball.
  Offset getShadowPosition(Offset ballCenter, double ballRadius) {
    return Offset(
      ballCenter.dx,
      ballCenter.dy + ballRadius,
    );
  }
}

// ==============================================================================
// BALL THEME EXTENSIONS
// ==============================================================================

/// Extension methods for ball-specific rendering helpers.
extension BallThemeExtensions on BallTheme {
  /// Get plastic/rubber material gradient.
  LinearGradient getPlasticGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    final highlight = Color.lerp(baseColor, Colors.white, 0.5)!;
    final shadow = Color.lerp(baseColor, Colors.black, 0.2)!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        highlight,
        baseColor,
        shadow,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Get glass/transparent ball gradient.
  ///
  /// For special effect balls or power-ups.
  RadialGradient getGlassBallGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor).withOpacity(0.6);
    final highlight = Colors.white.withOpacity(0.9);
    final edge = baseColor.withOpacity(0.8);

    return RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 1.0,
      colors: [
        highlight,
        baseColor,
        edge,
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  /// Check if a color should render with enhanced glossiness.
  bool shouldUseEnhancedGloss(GameColor gameColor) {
    return gameColor == GameColor.red ||
        gameColor == GameColor.blue ||
        gameColor == GameColor.yellow;
  }

  /// Get glossiness intensity for a specific color.
  double getGlossinessIntensity(GameColor gameColor) {
    if (shouldUseEnhancedGloss(gameColor)) {
      return 0.9; // Very glossy
    }
    return 0.7; // Standard glossiness
  }

  /// Create bounce animation curve for physics.
  ///
  /// This creates a realistic bouncing ball animation curve.
  Curve createBounceCurve({int bounces = 2}) {
    // Use built-in bounce curves for simplicity
    return switch (bounces) {
      1 => Curves.bounceOut,
      2 => Curves.bounceOut,
      3 => Curves.elasticOut,
      _ => Curves.bounceOut,
    };
  }

  /// Get ball shadow gradient.
  RadialGradient getBallShadowGradient(Offset center, double radius) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.black.withOpacity(ballShadowOpacity),
        Colors.black.withOpacity(ballShadowOpacity * 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
