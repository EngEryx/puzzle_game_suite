import 'package:flutter/material.dart';
import '../../core/models/game_color.dart';

/// Color mappings and utilities for the puzzle game.
///
/// DESIGN PHILOSOPHY:
/// - Vibrant, distinct colors for gameplay clarity
/// - High contrast for accessibility
/// - Colors chosen to work well together in small spaces
/// - Each color is easily distinguishable from others
///
/// Color selection criteria:
/// 1. Sufficient contrast ratio (WCAG AA minimum)
/// 2. Distinguishable for color-blind players where possible
/// 3. Appealing when rendered in tubes/containers
/// 4. Works on both light and dark backgrounds
class GameColors {
  // Prevent instantiation - this is a utility class
  GameColors._();

  /// Maps GameColor enum to actual Flutter Color values
  ///
  /// These are the base colors used for the main color fill.
  /// We use vibrant, saturated colors for maximum clarity.
  static const Map<GameColor, Color> colorMap = {
    // Primary colors - bold and clear
    GameColor.red: Color(0xFFE74C3C), // Bright red
    GameColor.blue: Color(0xFF3498DB), // Ocean blue
    GameColor.yellow: Color(0xFFF1C40F), // Sunflower yellow
    GameColor.green: Color(0xFF2ECC71), // Emerald green

    // Secondary colors - distinct and vibrant
    GameColor.purple: Color(0xFF9B59B6), // Amethyst purple
    GameColor.orange: Color(0xFFE67E22), // Carrot orange
    GameColor.pink: Color(0xFFE91E63), // Hot pink
    GameColor.cyan: Color(0xFF00BCD4), // Turquoise cyan

    // Additional colors for complex puzzles
    GameColor.brown: Color(0xFF8D6E63), // Warm brown
    GameColor.lime: Color(0xFF9CCC65), // Fresh lime
    GameColor.magenta: Color(0xFFAB47BC), // Bright magenta
    GameColor.teal: Color(0xFF009688), // Deep teal
  };

  /// Get the Flutter Color for a GameColor enum value
  ///
  /// Throws if the GameColor is not mapped (should never happen)
  static Color getColor(GameColor gameColor) {
    final color = colorMap[gameColor];
    if (color == null) {
      throw ArgumentError('No color mapping found for $gameColor');
    }
    return color;
  }

  /// Get a darker shade of a color for gradients/shadows
  ///
  /// Used to create depth and 3D effects in the container rendering.
  /// The darker shade is 30% darker than the base color.
  static Color getDarkerShade(GameColor gameColor) {
    final baseColor = getColor(gameColor);
    return Color.lerp(baseColor, Colors.black, 0.3)!;
  }

  /// Get a lighter shade of a color for highlights
  ///
  /// Used for gloss effects and highlights on the containers.
  /// The lighter shade is 30% lighter than the base color.
  static Color getLighterShade(GameColor gameColor) {
    final baseColor = getColor(gameColor);
    return Color.lerp(baseColor, Colors.white, 0.3)!;
  }

  /// Get a gradient for a color segment
  ///
  /// This creates a linear gradient from lighter (top) to darker (bottom)
  /// to give each color segment a 3D appearance.
  ///
  /// Why gradients?
  /// - Adds depth perception
  /// - Makes the game more visually appealing
  /// - Helps distinguish individual color segments
  /// - Creates a more polished, professional look
  static LinearGradient getColorGradient(GameColor gameColor) {
    final baseColor = getColor(gameColor);
    final lighter = getLighterShade(gameColor);
    final darker = getDarkerShade(gameColor);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lighter, // Top highlight
        baseColor, // Middle
        darker, // Bottom shadow
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Container colors
  ///
  /// These define the appearance of the container itself (the tube).
  /// Using neutral colors so they don't interfere with the game colors.
  static const Color containerOutline = Color(0xFF37474F); // Dark blue-grey
  static const Color containerBackground = Color(0xFFECEFF1); // Very light grey
  static const Color containerShadow = Color(0xFF263238); // Very dark grey

  /// Selection indicator color
  ///
  /// This color is used to highlight the selected container.
  /// Using a vibrant color that stands out from game colors.
  static const Color selectionColor = Color(0xFFFFEB3B); // Bright amber/gold

  /// Selection glow effect
  ///
  /// Creates a glowing border effect for the selected container.
  /// The glow has multiple layers for a soft, luminous effect.
  static List<BoxShadow> get selectionGlow => [
        BoxShadow(
          color: selectionColor.withOpacity(0.6),
          blurRadius: 8,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: selectionColor.withOpacity(0.3),
          blurRadius: 16,
          spreadRadius: 4,
        ),
      ];

  /// Get contrasting text color for a game color
  ///
  /// Returns white or black depending on the brightness of the color.
  /// Useful for displaying text on colored backgrounds.
  static Color getContrastColor(GameColor gameColor) {
    final color = getColor(gameColor);
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Check if two colors are similar (for UI purposes)
  ///
  /// This is used to ensure color segments are visually distinct.
  /// Returns true if colors might be confused by players.
  static bool areSimilar(GameColor color1, GameColor color2) {
    if (color1 == color2) return true;

    // Define similar color pairs that might be confused
    final similarPairs = [
      {GameColor.blue, GameColor.cyan},
      {GameColor.blue, GameColor.teal},
      {GameColor.purple, GameColor.magenta},
      {GameColor.green, GameColor.lime},
    ];

    for (final pair in similarPairs) {
      if (pair.contains(color1) && pair.contains(color2)) {
        return true;
      }
    }

    return false;
  }

  /// Get all available colors as a list
  ///
  /// Useful for level generation and testing.
  static List<GameColor> get allColors => GameColor.values;

  /// Get a subset of colors for a specific difficulty
  ///
  /// Easy levels use fewer, more distinct colors.
  /// Hard levels use more colors including similar ones.
  static List<GameColor> getColorsForDifficulty(int colorCount) {
    if (colorCount <= 0) return [];
    if (colorCount >= allColors.length) return allColors;

    // Return the most distinct colors first
    // This order prioritizes maximum visual distinction
    const orderedColors = [
      GameColor.red,
      GameColor.blue,
      GameColor.yellow,
      GameColor.green,
      GameColor.purple,
      GameColor.orange,
      GameColor.pink,
      GameColor.cyan,
      GameColor.brown,
      GameColor.lime,
      GameColor.magenta,
      GameColor.teal,
    ];

    return orderedColors.take(colorCount).toList();
  }
}
