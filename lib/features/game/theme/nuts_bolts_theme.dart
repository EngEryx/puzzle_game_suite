import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/game_color.dart';
import '../../../core/models/game_theme.dart';
import '../../../shared/constants/game_colors.dart';

/// Nuts and Bolts sorting theme implementation.
///
/// VISUAL STYLE:
/// - Metallic solid colors with reflective sheen
/// - Mechanical industrial appearance
/// - Workshop/garage background aesthetic
/// - Sharp geometric shapes
///
/// DESIGN PHILOSOPHY:
/// This theme transforms the puzzle into a mechanical sorting game:
/// - Solid metallic bolts instead of liquid
/// - Industrial container design
/// - Mechanical sound effects
/// - Workshop environment feel
///
/// GAMEPLAY VARIATION:
/// While the core mechanics remain the same, the visual representation
/// makes players feel like they're organizing hardware in a workshop
/// rather than sorting liquids.
///
/// PERFORMANCE:
/// - No translucency = faster rendering
/// - Simple metallic gradients
/// - Optimized for 60fps
///
class NutsAndBoltsTheme extends GameTheme {
  /// Singleton instance
  static final NutsAndBoltsTheme _instance = NutsAndBoltsTheme._internal();

  /// Factory constructor returns singleton
  factory NutsAndBoltsTheme() => _instance;

  /// Private constructor for singleton
  NutsAndBoltsTheme._internal();

  /// Cached color palette (lazy-loaded)
  Map<GameColor, Color>? _cachedPalette;

  @override
  ThemeType get type => ThemeType.nutsBolts;

  // ============================================================================
  // VISUAL STYLE
  // ============================================================================

  @override
  ContainerShape get containerShape => ContainerShape.rectangular;

  @override
  ColorStyle get colorStyle => ColorStyle.metallic;

  @override
  Gradient get backgroundGradient {
    // Workshop/garage gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF78909C), // Steel grey (top)
        Color(0xFF546E7A), // Dark steel (middle)
        Color(0xFF37474F), // Charcoal grey (bottom)
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  // ============================================================================
  // COLOR MAPPING
  // ============================================================================

  @override
  Color getColorForGameColor(GameColor gameColor) {
    // Nuts & Bolts theme uses solid metallic colors
    // Slightly saturated for vibrant metallic appearance
    final baseColor = GameColors.getColor(gameColor);

    // Increase saturation for metallic effect
    final hslColor = HSLColor.fromColor(baseColor);
    final metallicColor = hslColor
        .withSaturation((hslColor.saturation * 1.2).clamp(0.0, 1.0))
        .withLightness((hslColor.lightness * 0.9).clamp(0.0, 1.0))
        .toColor();

    return metallicColor; // Full opacity - solid metal
  }

  @override
  Map<GameColor, Color> getColorPalette() {
    // Use cached palette if available
    _cachedPalette ??= {
      // Solid metallic colors with enhanced saturation
      GameColor.red: const Color(0xFFD32F2F), // Metallic red
      GameColor.blue: const Color(0xFF1976D2), // Metallic blue
      GameColor.yellow: const Color(0xFFFBC02D), // Metallic yellow
      GameColor.green: const Color(0xFF388E3C), // Metallic green
      GameColor.purple: const Color(0xFF7B1FA2), // Metallic purple
      GameColor.orange: const Color(0xFFE64A19), // Metallic orange
      GameColor.pink: const Color(0xFFC2185B), // Metallic pink
      GameColor.cyan: const Color(0xFF0097A7), // Metallic cyan
      GameColor.brown: const Color(0xFF5D4037), // Metallic brown
      GameColor.lime: const Color(0xFF689F38), // Metallic lime
      GameColor.magenta: const Color(0xFF8E24AA), // Metallic magenta
      GameColor.teal: const Color(0xFF00796B), // Metallic teal
    };
    return _cachedPalette!;
  }

  @override
  LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColorForGameColor(gameColor);

    // Metallic gradient with strong highlights and shadows
    // This creates the appearance of polished metal
    final highlight = Color.lerp(baseColor, Colors.white, 0.4)!;
    final midHighlight = Color.lerp(baseColor, Colors.white, 0.2)!;
    final midShadow = Color.lerp(baseColor, Colors.black, 0.1)!;
    final shadow = Color.lerp(baseColor, Colors.black, 0.3)!;

    return LinearGradient(
      begin: Alignment.topLeft, // Angled for metallic reflection
      end: Alignment.bottomRight,
      colors: [
        highlight, // Top-left highlight (metal shine)
        midHighlight, // Upper region
        baseColor, // Middle (true color)
        midShadow, // Lower region
        shadow, // Bottom-right shadow
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
  }

  // ============================================================================
  // CONTAINER APPEARANCE
  // ============================================================================

  @override
  Color get containerOutlineColor => const Color(0xFF263238); // Dark metal

  @override
  double get containerOutlineWidth => 4.0; // Thicker for industrial look

  @override
  Color get containerBackgroundColor {
    // Dark industrial container interior
    return const Color(0xFF455A64);
  }

  @override
  List<BoxShadow> get containerShadows => [
        // Strong shadow for industrial depth
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(3, 4),
        ),
        // Inner shadow effect
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(1, 2),
        ),
      ];

  @override
  double get containerBorderRadius => 4.0; // Sharp corners for mechanical feel

  // ============================================================================
  // ANIMATION & EFFECTS
  // ============================================================================

  @override
  ParticleConfig getParticleConfig() {
    // Metal spark particles
    return ParticleConfig.metalSparks;
  }

  @override
  double get animationSpeedMultiplier => 0.8; // Faster, snappier for mechanical feel

  @override
  bool get showRippleEffects => false; // No ripples for solid objects

  @override
  bool get showSplashEffects => false; // No splashes for solid objects

  // ============================================================================
  // AUDIO
  // ============================================================================

  @override
  String? get pourSoundPath => 'assets/sounds/nuts_bolts/pour.mp3'; // Metallic clink

  @override
  String? get selectSoundPath => 'assets/sounds/nuts_bolts/select.mp3'; // Metal tap

  @override
  String? get winSoundPath => 'assets/sounds/nuts_bolts/win.mp3'; // Mechanical success

  @override
  String? get invalidMoveSoundPath => 'assets/sounds/nuts_bolts/invalid.mp3'; // Metal clang

  // ============================================================================
  // NUTS & BOLTS SPECIFIC FEATURES
  // ============================================================================

  /// Thread visualization settings.
  ///
  /// Nuts & Bolts theme can optionally render bolt threads
  /// for enhanced realism.
  bool get renderThreads => true;

  /// Thread spacing in pixels.
  double get threadSpacing => 4.0;

  /// Thread line width.
  double get threadWidth => 1.5;

  /// Thread color.
  Color get threadColor => Colors.white.withOpacity(0.2);

  /// Bolt head size as percentage of segment width.
  double get boltHeadSize => 0.8;

  /// Whether to render hexagonal bolt heads.
  bool get renderHexagonalHeads => true;

  /// Metallic shine position (0.0 = left, 1.0 = right).
  ///
  /// Controls where the specular highlight appears on bolts.
  double get shinePosition => 0.3;

  /// Metallic shine intensity (0.0 to 1.0).
  double get shineIntensity => 0.6;

  /// Create bolt path for rendering individual bolts.
  ///
  /// USAGE:
  /// Custom painters can use this to draw bolts instead of simple rectangles.
  ///
  /// PARAMETERS:
  /// - [rect]: The rectangle area to draw bolt in
  /// - [gameColor]: The color of the bolt
  ///
  /// RETURNS:
  /// - Path representing the bolt shape
  Path createBoltPath(Rect rect) {
    final path = Path();

    if (renderHexagonalHeads) {
      // Create hexagonal bolt head at top of segment
      final headHeight = rect.height * 0.2;
      final headWidth = rect.width * boltHeadSize;
      final headLeft = rect.left + (rect.width - headWidth) / 2;

      // Hexagon vertices
      final centerX = rect.centerLeft.dx + rect.width / 2;
      final topY = rect.top;
      final headBottomY = rect.top + headHeight;

      // Draw hexagon (6 sides)
      final angle = math.pi / 3; // 60 degrees
      for (int i = 0; i < 6; i++) {
        final x = centerX + (headWidth / 2) * math.cos(angle * i);
        final y = topY + headHeight / 2 + (headHeight / 2) * math.sin(angle * i);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      // Draw bolt shaft
      final shaftTop = headBottomY;
      final shaftRect = Rect.fromLTWH(
        headLeft + headWidth * 0.1,
        shaftTop,
        headWidth * 0.8,
        rect.height - headHeight,
      );
      path.addRect(shaftRect);
    } else {
      // Simple rectangular bolt
      path.addRect(rect);
    }

    return path;
  }

  /// Get metallic shine gradient overlay.
  ///
  /// This creates the characteristic metallic reflection.
  LinearGradient getMetallicShineGradient(Rect rect) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(shineIntensity),
        Colors.white.withOpacity(shineIntensity * 0.3),
        Colors.transparent,
        Colors.black.withOpacity(0.1),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Get thread line positions for rendering.
  ///
  /// Returns Y positions where thread lines should be drawn.
  List<double> getThreadPositions(Rect rect) {
    final positions = <double>[];
    var currentY = rect.top + threadSpacing;

    while (currentY < rect.bottom) {
      positions.add(currentY);
      currentY += threadSpacing;
    }

    return positions;
  }

  /// Get color for metal edge highlights.
  Color getEdgeHighlightColor(GameColor gameColor) {
    return Colors.white.withOpacity(0.4);
  }

  /// Get color for metal edge shadows.
  Color getEdgeShadowColor(GameColor gameColor) {
    return Colors.black.withOpacity(0.3);
  }
}

// ==============================================================================
// NUTS & BOLTS THEME EXTENSIONS
// ==============================================================================

/// Extension methods for nuts & bolts specific rendering helpers.
extension NutsAndBoltsThemeExtensions on NutsAndBoltsTheme {
  /// Get industrial metal gradient for container.
  LinearGradient getIndustrialContainerGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF607D8B), // Light steel
        const Color(0xFF546E7A), // Medium steel
        const Color(0xFF455A64), // Dark steel
        const Color(0xFF37474F), // Darker steel
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Check if a color should render with enhanced metallic effect.
  ///
  /// Some colors (silver-like) benefit from stronger metallic rendering.
  bool shouldUseEnhancedMetallic(GameColor gameColor) {
    return gameColor == GameColor.blue ||
        gameColor == GameColor.cyan ||
        gameColor == GameColor.purple;
  }

  /// Get metallic intensity for a specific color.
  double getMetallicIntensity(GameColor gameColor) {
    if (shouldUseEnhancedMetallic(gameColor)) {
      return 0.8; // Strong metallic effect
    }
    return 0.6; // Standard metallic effect
  }

  /// Create rivet decoration positions for container.
  ///
  /// Industrial containers often have decorative rivets.
  List<Offset> getRivetPositions(Rect containerRect) {
    final rivets = <Offset>[];

    // Corner rivets
    const margin = 8.0;
    rivets.addAll([
      Offset(containerRect.left + margin, containerRect.top + margin),
      Offset(containerRect.right - margin, containerRect.top + margin),
      Offset(containerRect.left + margin, containerRect.bottom - margin),
      Offset(containerRect.right - margin, containerRect.bottom - margin),
    ]);

    return rivets;
  }

  /// Get rivet color (dark metal).
  Color get rivetColor => const Color(0xFF263238);

  /// Get rivet size.
  double get rivetRadius => 3.0;
}
