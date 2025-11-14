import 'package:flutter/material.dart';
import '../../../core/models/game_color.dart';
import '../../../core/models/game_theme.dart';
import '../../../shared/constants/game_colors.dart';

/// Test tube / laboratory theme implementation.
///
/// VISUAL STYLE:
/// - Scientific test tube containers
/// - Chemical liquid appearance
/// - Laboratory background aesthetic
/// - Translucent colorful solutions with bubbles
///
/// DESIGN PHILOSOPHY:
/// This theme transforms the puzzle into a chemistry lab experience:
/// - Scientific test tubes instead of generic containers
/// - Chemical solution appearance (slightly translucent)
/// - Laboratory/science atmosphere
/// - Bubbling and mixing effects
///
/// GAMEPLAY VARIATION:
/// The scientific theme appeals to players who enjoy educational
/// or STEM-themed games, making chemistry feel fun and approachable.
///
/// PERFORMANCE:
/// - Moderate translucency (better than water, different feel)
/// - Bubble particle effects
/// - Optimized for 60fps with smooth chemical animations
///
class TestTubeTheme extends GameTheme {
  /// Singleton instance
  static final TestTubeTheme _instance = TestTubeTheme._internal();

  /// Factory constructor returns singleton
  factory TestTubeTheme() => _instance;

  /// Private constructor for singleton
  TestTubeTheme._internal();

  /// Cached color palette (lazy-loaded)
  Map<GameColor, Color>? _cachedPalette;

  @override
  ThemeType get type => ThemeType.testTubes;

  // ============================================================================
  // VISUAL STYLE
  // ============================================================================

  @override
  ContainerShape get containerShape => ContainerShape.cylindrical;

  @override
  ColorStyle get colorStyle => ColorStyle.translucent;

  @override
  Gradient get backgroundGradient {
    // Laboratory/science gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFECEFF1), // Clean white (top)
        Color(0xFFCFD8DC), // Light grey (middle)
        Color(0xFFB0BEC5), // Medium grey (bottom)
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // COLOR MAPPING
  // ============================================================================

  @override
  Color getColorForGameColor(GameColor gameColor) {
    // Test tube theme uses moderately translucent chemical colors
    // More opaque than water (80%) for chemical solution appearance
    final baseColor = GameColors.getColor(gameColor);

    // Slightly adjust colors for chemical appearance
    final hslColor = HSLColor.fromColor(baseColor);
    final chemicalColor = hslColor
        .withSaturation((hslColor.saturation * 1.05).clamp(0.0, 1.0))
        .toColor();

    return chemicalColor.withOpacity(0.8); // 80% opacity - chemical solution
  }

  @override
  Map<GameColor, Color> getColorPalette() {
    // Use cached palette if available
    _cachedPalette ??= {
      // Chemical solution colors (moderately translucent)
      GameColor.red: const Color(0xFFE74C3C).withOpacity(0.8),
      GameColor.blue: const Color(0xFF3498DB).withOpacity(0.8),
      GameColor.yellow: const Color(0xFFF1C40F).withOpacity(0.8),
      GameColor.green: const Color(0xFF2ECC71).withOpacity(0.8),
      GameColor.purple: const Color(0xFF9B59B6).withOpacity(0.8),
      GameColor.orange: const Color(0xFFE67E22).withOpacity(0.8),
      GameColor.pink: const Color(0xFFE91E63).withOpacity(0.8),
      GameColor.cyan: const Color(0xFF00BCD4).withOpacity(0.8),
      GameColor.brown: const Color(0xFF8D6E63).withOpacity(0.8),
      GameColor.lime: const Color(0xFF9CCC65).withOpacity(0.8),
      GameColor.magenta: const Color(0xFFAB47BC).withOpacity(0.8),
      GameColor.teal: const Color(0xFF009688).withOpacity(0.8),
    };
    return _cachedPalette!;
  }

  @override
  LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);

    // Chemical solution gradient with subtle layering
    // Simulates concentration differences in the liquid
    final lighter = Color.lerp(baseColor, Colors.white, 0.2)!;
    final darker = Color.lerp(baseColor, Colors.black, 0.15)!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lighter.withOpacity(0.75), // Top (less concentrated)
        baseColor, // Middle (normal concentration)
        baseColor.withOpacity(0.85), // Lower middle
        darker, // Bottom (more concentrated)
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );
  }

  // ============================================================================
  // CONTAINER APPEARANCE
  // ============================================================================

  @override
  Color get containerOutlineColor => const Color(0xFF78909C); // Glass grey-blue

  @override
  double get containerOutlineWidth => 2.5; // Thinner for glass appearance

  @override
  Color get containerBackgroundColor {
    // Very light, almost transparent tube interior
    return const Color(0xFFFAFAFA);
  }

  @override
  List<BoxShadow> get containerShadows => [
        // Subtle shadow for glass tube
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(2, 3),
        ),
        // Glass reflection shadow
        BoxShadow(
          color: Colors.white.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(-1, -1),
        ),
      ];

  @override
  double get containerBorderRadius => 8.0; // Moderate rounding for tube

  // ============================================================================
  // ANIMATION & EFFECTS
  // ============================================================================

  @override
  ParticleConfig getParticleConfig() {
    // Bubble particles for chemical reactions
    return ParticleConfig.bubbles;
  }

  @override
  double get animationSpeedMultiplier => 1.0; // Normal chemical pour speed

  @override
  bool get showRippleEffects => true; // Chemical solutions show ripples

  @override
  bool get showSplashEffects => true; // Splashing chemical solutions

  // ============================================================================
  // AUDIO
  // ============================================================================

  @override
  String? get pourSoundPath => 'assets/sounds/test_tubes/pour.mp3'; // Bubbling liquid

  @override
  String? get selectSoundPath => 'assets/sounds/test_tubes/select.mp3'; // Glass clink

  @override
  String? get winSoundPath => 'assets/sounds/test_tubes/win.mp3'; // Success chime

  @override
  String? get invalidMoveSoundPath => 'assets/sounds/test_tubes/invalid.mp3'; // Error beep

  // ============================================================================
  // TEST TUBE SPECIFIC FEATURES
  // ============================================================================

  /// Whether to render measurement markings on tubes.
  bool get renderMeasurements => true;

  /// Number of measurement lines to show.
  int get measurementLineCount => 4;

  /// Measurement line color.
  Color get measurementLineColor => Colors.black.withOpacity(0.3);

  /// Measurement line width.
  double get measurementLineWidth => 1.0;

  /// Whether to show bubble effects in solutions.
  bool get renderBubbles => true;

  /// Bubble density (bubbles per segment).
  int get bubbleDensity => 3;

  /// Bubble size range.
  double get minBubbleSize => 2.0;
  double get maxBubbleSize => 5.0;

  /// Bubble rise speed multiplier.
  double get bubbleRiseSpeed => 1.0;

  /// Whether to render glass reflection effect.
  bool get renderGlassReflection => true;

  /// Glass reflection intensity.
  double get glassReflectionIntensity => 0.4;

  /// Whether to show meniscus (curved liquid surface).
  bool get renderMeniscus => true;

  /// Meniscus curvature (0.0 = flat, 1.0 = very curved).
  double get meniscusCurvature => 0.3;

  /// Get measurement line positions.
  ///
  /// PARAMETERS:
  /// - [containerRect]: The tube rectangle
  ///
  /// RETURNS:
  /// - List of Y positions for measurement lines
  List<double> getMeasurementLinePositions(Rect containerRect) {
    final positions = <double>[];
    final segmentHeight = containerRect.height / (measurementLineCount + 1);

    for (int i = 1; i <= measurementLineCount; i++) {
      positions.add(containerRect.top + (segmentHeight * i));
    }

    return positions;
  }

  /// Create meniscus path for liquid surface.
  ///
  /// The meniscus is the curved surface of a liquid in a tube.
  ///
  /// PARAMETERS:
  /// - [rect]: The liquid surface area
  ///
  /// RETURNS:
  /// - Path representing the curved meniscus
  Path createMeniscusPath(Rect rect) {
    final path = Path();

    final startX = rect.left;
    final endX = rect.right;
    final baseY = rect.top;
    final width = rect.width;

    // Start at left edge
    path.moveTo(startX, baseY);

    // Create smooth curve using quadratic bezier
    final controlX = startX + width / 2;
    final controlY = baseY - (width * meniscusCurvature * 0.1); // Slight upward curve

    path.quadraticBezierTo(controlX, controlY, endX, baseY);

    return path;
  }

  /// Get glass reflection gradient.
  ///
  /// Creates the appearance of light reflecting off glass tube.
  LinearGradient getGlassReflectionGradient(Rect containerRect) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(glassReflectionIntensity),
        Colors.white.withOpacity(glassReflectionIntensity * 0.5),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.15, 0.3, 0.5],
    );
  }

  /// Generate bubble positions for a segment.
  ///
  /// PARAMETERS:
  /// - [segmentRect]: The liquid segment rectangle
  /// - [seed]: Random seed for consistent bubble placement
  ///
  /// RETURNS:
  /// - List of bubble positions and sizes
  List<BubbleInfo> generateBubbles(Rect segmentRect, int seed) {
    final bubbles = <BubbleInfo>[];

    // Use deterministic "random" based on seed for consistency
    for (int i = 0; i < bubbleDensity; i++) {
      // Pseudo-random position (deterministic based on i and seed)
      final xRatio = ((seed * 7 + i * 13) % 100) / 100.0;
      final yRatio = ((seed * 11 + i * 17) % 100) / 100.0;

      final x = segmentRect.left + segmentRect.width * xRatio;
      final y = segmentRect.top + segmentRect.height * yRatio;

      // Pseudo-random size
      final sizeRatio = ((seed * 3 + i * 5) % 100) / 100.0;
      final size = minBubbleSize + (maxBubbleSize - minBubbleSize) * sizeRatio;

      bubbles.add(BubbleInfo(
        position: Offset(x, y),
        size: size,
      ));
    }

    return bubbles;
  }

  /// Get chemical solution shimmer effect.
  ///
  /// Creates a subtle shimmer in the liquid for realism.
  LinearGradient getChemicalShimmerGradient(
    GameColor gameColor,
    double animationValue,
  ) {
    final baseColor = getColorForGameColor(gameColor);
    final shimmer = Color.lerp(baseColor, Colors.white, 0.3)!;

    // Animate shimmer position
    final shimmerPosition = 0.3 + (animationValue * 0.4);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        shimmer.withOpacity(0.3),
        baseColor,
      ],
      stops: [
        (shimmerPosition - 0.1).clamp(0.0, 1.0),
        shimmerPosition.clamp(0.0, 1.0),
        (shimmerPosition + 0.1).clamp(0.0, 1.0),
      ],
    );
  }

  /// Get foam/froth effect for surface.
  ///
  /// Some chemical solutions have foam on top.
  Color getFoamColor(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);
    return Color.lerp(baseColor, Colors.white, 0.6)!.withOpacity(0.5);
  }
}

// ==============================================================================
// SUPPORTING TYPES
// ==============================================================================

/// Information about a bubble particle.
class BubbleInfo {
  final Offset position;
  final double size;

  const BubbleInfo({
    required this.position,
    required this.size,
  });

  /// Create bubble with animation offset.
  ///
  /// Bubbles rise over time in animations.
  BubbleInfo withRiseOffset(double riseAmount) {
    return BubbleInfo(
      position: Offset(position.dx, position.dy - riseAmount),
      size: size,
    );
  }

  /// Check if bubble has risen out of bounds.
  bool isOutOfBounds(Rect bounds) {
    return position.dy < bounds.top;
  }
}

// ==============================================================================
// TEST TUBE THEME EXTENSIONS
// ==============================================================================

/// Extension methods for test tube specific rendering helpers.
extension TestTubeThemeExtensions on TestTubeTheme {
  /// Get scientific color palette with chemical names.
  ///
  /// Maps game colors to chemistry-themed names.
  Map<GameColor, String> getChemicalNames() {
    return {
      GameColor.red: 'Phenolphthalein',
      GameColor.blue: 'Copper Sulfate',
      GameColor.yellow: 'Sodium Chromate',
      GameColor.green: 'Nickel Chloride',
      GameColor.purple: 'Potassium Permanganate',
      GameColor.orange: 'Dichromate',
      GameColor.pink: 'Cobalt Chloride',
      GameColor.cyan: 'Copper Acetate',
      GameColor.brown: 'Iron Oxide',
      GameColor.lime: 'Uranium Glass',
      GameColor.magenta: 'Rhodamine',
      GameColor.teal: 'Copper Carbonate',
    };
  }

  /// Get tube neck position for test tube shape.
  ///
  /// Test tubes have a narrow neck at the top.
  Rect getTubeNeck(Rect containerRect) {
    final neckHeight = containerRect.height * 0.15;
    final neckWidth = containerRect.width * 0.7;
    final neckLeft = containerRect.left + (containerRect.width - neckWidth) / 2;

    return Rect.fromLTWH(
      neckLeft,
      containerRect.top,
      neckWidth,
      neckHeight,
    );
  }

  /// Get tube body position.
  Rect getTubeBody(Rect containerRect) {
    final neckHeight = containerRect.height * 0.15;

    return Rect.fromLTWH(
      containerRect.left,
      containerRect.top + neckHeight,
      containerRect.width,
      containerRect.height - neckHeight,
    );
  }

  /// Check if a color should render with bubbles.
  ///
  /// Some chemical colors are more effervescent.
  bool shouldShowBubbles(GameColor gameColor) {
    return gameColor == GameColor.green ||
        gameColor == GameColor.yellow ||
        gameColor == GameColor.cyan ||
        gameColor == GameColor.blue;
  }

  /// Get bubble intensity for a specific color.
  int getBubbleIntensity(GameColor gameColor) {
    if (shouldShowBubbles(gameColor)) {
      return bubbleDensity * 2; // More bubbles
    }
    return bubbleDensity; // Normal bubbles
  }

  /// Create graduated measurement labels.
  ///
  /// Test tubes have volume markings.
  List<String> getMeasurementLabels(int capacity) {
    final labels = <String>[];
    final increment = capacity;

    for (int i = 1; i <= measurementLineCount; i++) {
      final value = i * increment ~/ (measurementLineCount + 1);
      labels.add('${value}ml');
    }

    return labels;
  }
}
