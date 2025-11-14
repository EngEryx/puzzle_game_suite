/// Represents a color in the puzzle game.
///
/// This is the fundamental building block of our game state.
/// Using an enum ensures type safety and prevents invalid color values.
///
/// Why enum vs String/int?
/// - Type safety: Can't accidentally use wrong color
/// - Exhaustive checking: Compiler ensures all cases handled
/// - Performance: Enums are fast (compiled to integers)
enum GameColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
  pink,
  cyan,
  brown,
  lime,
  magenta,
  teal;

  /// Display name for UI
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}
