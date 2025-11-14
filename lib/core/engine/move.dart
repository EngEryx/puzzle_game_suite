import '../models/game_color.dart';

/// Represents a single move in the puzzle game.
///
/// KEY CONCEPT: Value Objects
///
/// This is a "value object" - an immutable object whose equality is based
/// on its values, not its identity. Like a number or string, two Moves with
/// the same values are considered equal.
///
/// Why value objects for moves?
/// 1. **History tracking**: Store moves for undo/redo without side effects
/// 2. **Network safety**: Can serialize and send over network reliably
/// 3. **Debugging**: Can log and inspect moves without worrying about mutation
/// 4. **Testing**: Easy to create and compare expected vs actual moves
///
/// Backend analogy:
/// Think of this like a database transaction record - once created, it's
/// immutable and represents what happened at a specific point in time.
/// Just like you wouldn't modify a transaction log entry, you don't modify a Move.
///
/// Performance implications:
/// - Creating new Move objects is cheap (O(1) allocation)
/// - No defensive copying needed (immutable = safe to share)
/// - Dart compiler can optimize immutable objects
/// - Flutter's widget tree works well with immutable data
class Move {
  /// ID of the container we're pouring FROM
  final String fromContainerId;

  /// ID of the container we're pouring TO
  final String toContainerId;

  /// The color being moved
  ///
  /// This is redundant with container state but stored here for:
  /// 1. Move history clarity (know what was moved without looking up state)
  /// 2. Undo validation (verify the move makes sense)
  /// 3. Animation hints (know what color to animate)
  final GameColor color;

  /// How many units of the color are being moved
  ///
  /// In our game, we move all contiguous top colors at once.
  /// Example: If top of container has [red, blue, blue, blue],
  /// we would move all 3 blues in one move.
  ///
  /// This is stored for:
  /// 1. Animation (need to know how many items to animate)
  /// 2. Undo (need to know how many to move back)
  /// 3. Scoring (could award points based on count)
  final int count;

  /// Create a new Move
  ///
  /// All parameters are required because a partial move doesn't make sense.
  /// A move without a source, destination, color, or count is invalid.
  const Move({
    required this.fromContainerId,
    required this.toContainerId,
    required this.color,
    required this.count,
  });

  /// Create the reverse of this move for undo functionality.
  ///
  /// This is a key method for implementing undo/redo.
  /// Instead of storing "before" and "after" states (memory expensive),
  /// we just store moves and their reverses.
  ///
  /// Example:
  /// ```dart
  /// final move = Move(from: 'A', to: 'B', color: red, count: 2);
  /// final undo = move.reverse(); // from: 'B', to: 'A', color: red, count: 2
  /// ```
  ///
  /// Performance note:
  /// - O(1) operation, just swaps two string references
  /// - No deep copying needed
  /// - Can pre-compute and store if needed for instant undo
  ///
  /// Backend pattern:
  /// Similar to compensating transactions in distributed systems.
  /// Instead of rollback, we apply the inverse operation.
  Move reverse() {
    return Move(
      fromContainerId: toContainerId, // Swap source and destination
      toContainerId: fromContainerId,
      color: color, // Color and count stay the same
      count: count,
    );
  }

  // ==================== EQUALITY & DEBUGGING ====================

  /// Two moves are equal if all their values match.
  ///
  /// This is crucial for:
  /// 1. Testing (verify correct move was made)
  /// 2. Move history (detect duplicate moves)
  /// 3. Undo/redo (match moves to their reverses)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Move) return false;

    return fromContainerId == other.fromContainerId &&
        toContainerId == other.toContainerId &&
        color == other.color &&
        count == other.count;
  }

  @override
  int get hashCode => Object.hash(
        fromContainerId,
        toContainerId,
        color,
        count,
      );

  @override
  String toString() {
    return 'Move($count x ${color.name}: $fromContainerId → $toContainerId)';
  }

  /// Detailed debug representation
  String toDebugString() {
    return 'Move {\n'
        '  from: $fromContainerId\n'
        '  to: $toContainerId\n'
        '  color: ${color.name}\n'
        '  count: $count\n'
        '}';
  }
}
