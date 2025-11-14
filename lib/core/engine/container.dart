import '../models/game_color.dart';

/// Represents a game container (tube/bolt/ball holder).
///
/// KEY CONCEPT: Immutability in Game State
///
/// Why immutable?
/// 1. Predictability: Same state always produces same result
/// 2. Undo/Redo: Can store previous states easily
/// 3. Testing: Pure functions are easier to test
/// 4. Performance: Flutter can optimize immutable widgets
/// 5. Thread-safety: No race conditions
///
/// Think of it like database transactions:
/// - Never modify existing state directly
/// - Always create new state from old state
/// - Old state remains valid for rollback
class Container {
  /// Unique identifier for this container
  final String id;

  /// Colors in the container, bottom to top
  /// Empty list = empty container
  /// [red, blue, blue] = red at bottom, two blues on top
  final List<GameColor> colors;

  /// Maximum number of colors this container can hold
  final int capacity;

  /// Create a new container
  ///
  /// Note: We make a defensive copy of colors list to ensure immutability
  const Container({
    required this.id,
    required this.colors,
    required this.capacity,
  });

  /// Create an empty container
  factory Container.empty({
    required String id,
    int capacity = 4,
  }) {
    return Container(
      id: id,
      colors: const [],
      capacity: capacity,
    );
  }

  /// Create container with initial colors
  factory Container.withColors({
    required String id,
    required List<GameColor> colors,
    int capacity = 4,
  }) {
    return Container(
      id: id,
      colors: List.unmodifiable(colors),
      capacity: capacity,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================
  // These are derived from the state, not stored
  // Think of them like SQL views - calculated on demand

  /// Is this container empty?
  bool get isEmpty => colors.isEmpty;

  /// Is this container full?
  bool get isFull => colors.length >= capacity;

  /// Is this container solved?
  ///
  /// A container is solved if:
  /// - It's empty, OR
  /// - It's full AND all colors are the same
  bool get isSolved {
    if (isEmpty) return true;
    if (!isFull) return false;
    return colors.every((color) => color == colors.first);
  }

  /// Get the top color (the one that would be poured out)
  /// Returns null if container is empty
  GameColor? get topColor => isEmpty ? null : colors.last;

  /// How many of the top color are stacked together?
  ///
  /// Example: [red, blue, blue, blue] returns 3
  /// This is important for move validation and animation
  int get topColorCount {
    if (isEmpty) return 0;

    final top = topColor!;
    int count = 0;

    // Count from the top down while colors match
    for (int i = colors.length - 1; i >= 0; i--) {
      if (colors[i] == top) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  /// Available space in container
  int get availableSpace => capacity - colors.length;

  // ==================== IMMUTABLE OPERATIONS ====================
  // These return NEW containers, never modify this one

  /// Add a color to the top of this container
  ///
  /// Returns a NEW container with the color added
  /// Original container is unchanged (immutability!)
  Container addColor(GameColor color) {
    return Container(
      id: id,
      colors: [...colors, color],
      capacity: capacity,
    );
  }

  /// Add multiple colors to the top
  Container addColors(List<GameColor> newColors) {
    return Container(
      id: id,
      colors: [...colors, ...newColors],
      capacity: capacity,
    );
  }

  /// Remove N colors from the top
  ///
  /// Returns a NEW container with colors removed
  Container removeTopColors(int count) {
    if (count > colors.length) {
      throw ArgumentError('Cannot remove $count colors, only have ${colors.length}');
    }

    return Container(
      id: id,
      colors: colors.sublist(0, colors.length - count),
      capacity: capacity,
    );
  }

  /// Create a copy of this container with changes
  ///
  /// This is the standard pattern for immutable updates
  /// Similar to Object.assign() in JavaScript or array_merge() in PHP
  Container copyWith({
    String? id,
    List<GameColor>? colors,
    int? capacity,
  }) {
    return Container(
      id: id ?? this.id,
      colors: colors ?? this.colors,
      capacity: capacity ?? this.capacity,
    );
  }

  // ==================== EQUALITY & DEBUGGING ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Container) return false;

    // Check all properties
    if (id != other.id) return false;
    if (capacity != other.capacity) return false;
    if (colors.length != other.colors.length) return false;

    // Check each color
    for (int i = 0; i < colors.length; i++) {
      if (colors[i] != other.colors[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    capacity,
    Object.hashAll(colors),
  );

  @override
  String toString() {
    return 'Container(id: $id, colors: $colors, capacity: $capacity)';
  }

  /// Debug representation showing container visually
  String toDebugString() {
    if (isEmpty) {
      return 'Container $id: [empty]';
    }

    final colorNames = colors.map((c) => c.name).join(', ');
    return 'Container $id: [$colorNames] (${colors.length}/$capacity)';
  }
}
