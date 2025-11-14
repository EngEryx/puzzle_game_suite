import 'container.dart';
import '../models/level.dart';

/// Represents a single move in the game.
///
/// DESIGN PRINCIPLE: Moves as Commands
///
/// This is the Command Pattern from design patterns:
/// - Encapsulates an action as an object
/// - Can be stored, logged, undone, replayed
/// - Makes undo/redo trivial (just reverse the command)
///
/// Similar to:
/// - Git commits (atomic changes)
/// - Database transactions (before/after state)
/// - Event sourcing (stream of events)
/// - Redux actions (dispatched events)
class Move {
  /// Container to pour from
  final String fromContainerId;

  /// Container to pour to
  final String toContainerId;

  /// How many colors were moved
  ///
  /// This is important for:
  /// - Undo operation (need to know how many to reverse)
  /// - Animation (show N colors moving)
  /// - Analytics (track move efficiency)
  final int colorsMoved;

  /// Timestamp when move was made
  final DateTime timestamp;

  const Move({
    required this.fromContainerId,
    required this.toContainerId,
    required this.colorsMoved,
    required this.timestamp,
  });

  /// Create a move with current timestamp
  factory Move.now({
    required String fromContainerId,
    required String toContainerId,
    required int colorsMoved,
  }) {
    return Move(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      colorsMoved: colorsMoved,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Move($fromContainerId → $toContainerId, $colorsMoved colors)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Move &&
        other.fromContainerId == fromContainerId &&
        other.toContainerId == toContainerId &&
        other.colorsMoved == colorsMoved;
  }

  @override
  int get hashCode => Object.hash(fromContainerId, toContainerId, colorsMoved);
}

/// Validates whether a move is legal.
///
/// SINGLE RESPONSIBILITY PRINCIPLE:
/// Separating validation from state management keeps code clean.
/// This class only cares about "can this move be made?"
/// GameState cares about "apply this move to create new state"
class MoveValidator {
  /// Check if a move from one container to another is valid
  ///
  /// VALIDATION RULES:
  /// 1. Source container must not be empty
  /// 2. Target container must not be full
  /// 3. Colors must match (or target is empty)
  /// 4. Can't pour to same container
  /// 5. Target must have space for at least 1 color
  ///
  /// Returns error message if invalid, null if valid
  static String? validateMove(Container from, Container to) {
    // Rule 1: Can't pour from empty container
    if (from.isEmpty) {
      return 'Source container is empty';
    }

    // Rule 2: Can't pour to same container
    if (from.id == to.id) {
      return 'Cannot pour into the same container';
    }

    // Rule 3: Can't pour to full container
    if (to.isFull) {
      return 'Target container is full';
    }

    // Rule 4: Colors must match (if target not empty)
    if (!to.isEmpty && to.topColor != from.topColor) {
      return 'Colors do not match (${from.topColor?.name} != ${to.topColor?.name})';
    }

    // Rule 5: Must have space for at least 1 color
    if (to.availableSpace < 1) {
      return 'Target container has no available space';
    }

    return null; // Move is valid
  }

  /// Calculate how many colors would be moved
  ///
  /// This determines the actual pour amount:
  /// - Limited by source color stack (can't pour mixed colors)
  /// - Limited by target space (can't overflow)
  ///
  /// Example:
  /// - From: [red, blue, blue, blue] (3 blues on top)
  /// - To: [red, red] (capacity 4, space for 2)
  /// - Result: 2 (pour 2 blues, limited by space)
  static int calculateMoveAmount(Container from, Container to) {
    if (from.isEmpty) return 0;

    // How many of top color can we move?
    final availableColors = from.topColorCount;

    // How much space does target have?
    final availableSpace = to.availableSpace;

    // Move the smaller amount
    return availableColors < availableSpace ? availableColors : availableSpace;
  }
}

/// Immutable game state.
///
/// ═══════════════════════════════════════════════════════════════════
/// CORE CONCEPT: Immutability in Game State Management
/// ═══════════════════════════════════════════════════════════════════
///
/// WHY IMMUTABLE STATE?
///
/// 1. TIME TRAVEL / UNDO-REDO
///    - Each state is a snapshot in time
///    - Can store entire state history
///    - Undo = load previous snapshot
///    - Redo = load next snapshot
///    - No complex "reverse operation" logic needed
///
///    Think of it like Git:
///    - Each commit is immutable
///    - Can checkout any previous commit
///    - Can't modify old commits, only create new ones
///
/// 2. PREDICTABILITY
///    - Same input always produces same output (pure functions)
///    - No hidden side effects
///    - Easy to test: state1 + action = state2
///    - No "spooky action at a distance"
///
///    Example of MUTABLE problems:
///    ```dart
///    var state = GameState(...);
///    doSomething(state);  // Did this modify state? Who knows!
///    ```
///
///    With IMMUTABLE:
///    ```dart
///    final state = GameState(...);
///    final newState = state.applyMove(...);  // Clear: new state created
///    ```
///
/// 3. PERFORMANCE (Flutter specific)
///    - Flutter rebuilds widgets when state changes
///    - With immutable state, change detection is trivial:
///      oldState == newState (just compare references!)
///    - With mutable state, need deep comparison:
///      Check every field, every item in lists, etc.
///
/// 4. THREAD SAFETY
///    - Immutable objects are inherently thread-safe
///    - Can share across isolates without locks
///    - No race conditions possible
///
/// 5. DEBUGGING
///    - Can log every state transition
///    - Can replay bug scenarios exactly
///    - Can visualize state history (dev tools)
///
/// ═══════════════════════════════════════════════════════════════════
/// COMPARISON TO OTHER ARCHITECTURES
/// ═══════════════════════════════════════════════════════════════════
///
/// REDUX (React/JavaScript):
/// ```javascript
/// const newState = reducer(oldState, action);
/// // Never: oldState.count++ (mutation!)
/// // Always: { ...oldState, count: oldState.count + 1 } (new object)
/// ```
///
/// BACKEND STATE MACHINES:
/// - Order state: pending → processing → shipped → delivered
/// - Each transition creates new record (audit trail)
/// - Old states preserved for history/rollback
///
/// EVENT SOURCING:
/// - Store stream of events, not current state
/// - Rebuild state by replaying events
/// - Our move history is a simple form of this
///
/// DATABASE TRANSACTIONS:
/// - ACID properties (Atomicity, Consistency, Isolation, Durability)
/// - Each move is atomic (all or nothing)
/// - Can rollback to savepoint
///
/// ═══════════════════════════════════════════════════════════════════
class GameState {
  /// Current container states
  ///
  /// IMPORTANT: This is a List, but we treat it as immutable.
  /// We never modify this list, only create new lists.
  final List<Container> containers;

  /// History of all moves made
  ///
  /// This enables:
  /// - Undo (pop last move, apply reverse)
  /// - Move counter (moveHistory.length)
  /// - Replay (re-apply all moves from start)
  /// - Analytics (which moves were made)
  final List<Move> moveHistory;

  /// The level being played
  ///
  /// Contains:
  /// - Move limit (if any)
  /// - Star thresholds
  /// - Initial configuration
  final Level level;

  const GameState({
    required this.containers,
    required this.moveHistory,
    required this.level,
  });

  /// Create initial game state from a level
  ///
  /// This is the "constructor" for starting a game
  factory GameState.fromLevel(Level level) {
    return GameState(
      containers: level.initialContainers,
      moveHistory: const [],
      level: level,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================
  // These are derived from state, not stored
  // Think of them like SQL views or computed columns

  /// Current move count
  int get moveCount => moveHistory.length;

  /// Moves remaining (if level has limit)
  int? get movesRemaining {
    if (level.moveLimit == null) return null;
    return level.moveLimit! - moveCount;
  }

  /// Is the game won?
  ///
  /// Win condition: All containers are solved
  /// (Either empty OR full with single color)
  bool get isWon {
    return containers.every((container) => container.isSolved);
  }

  /// Is the game lost?
  ///
  /// Loss condition: Move limit exceeded and not won
  bool get isLost {
    if (level.moveLimit == null) return false;
    return moveCount >= level.moveLimit! && !isWon;
  }

  /// Is the game over? (won or lost)
  bool get isGameOver => isWon || isLost;

  /// Can undo? (has move history)
  bool get canUndo => moveHistory.isNotEmpty;

  /// Get current star rating
  ///
  /// Only valid if game is won
  int get currentStars {
    if (!isWon) return 0;
    return level.calculateStars(moveCount);
  }

  /// Get container by ID
  ///
  /// Returns null if not found
  Container? getContainer(String id) {
    try {
      return containers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== STATE TRANSITIONS ====================
  // These return NEW states, never modify this one

  /// Apply a move and return new state
  ///
  /// IMMUTABILITY IN ACTION:
  /// 1. Validate move (check if legal)
  /// 2. Calculate move amount
  /// 3. Create new containers with updated colors
  /// 4. Create new move record
  /// 5. Return NEW GameState with updates
  /// 6. This GameState remains unchanged
  ///
  /// This is a PURE FUNCTION:
  /// - Same inputs always produce same output
  /// - No side effects (doesn't modify anything)
  /// - Deterministic and testable
  ///
  /// ANALOGY: Like Array.map() in JavaScript
  /// ```javascript
  /// const oldArray = [1, 2, 3];
  /// const newArray = oldArray.map(x => x * 2);  // [2, 4, 6]
  /// // oldArray is still [1, 2, 3] (unchanged)
  /// ```
  GameState applyMove({
    required String fromId,
    required String toId,
  }) {
    // Find containers
    final fromContainer = getContainer(fromId);
    final toContainer = getContainer(toId);

    if (fromContainer == null) {
      throw ArgumentError('Source container not found: $fromId');
    }
    if (toContainer == null) {
      throw ArgumentError('Target container not found: $toId');
    }

    // Validate move
    final error = MoveValidator.validateMove(fromContainer, toContainer);
    if (error != null) {
      throw ArgumentError('Invalid move: $error');
    }

    // Calculate how many colors to move
    final amount = MoveValidator.calculateMoveAmount(fromContainer, toContainer);

    // Get the colors to move
    final colorsToMove = fromContainer.colors
        .sublist(fromContainer.colors.length - amount);

    // Create new containers (immutable updates)
    final updatedFrom = fromContainer.removeTopColors(amount);
    final updatedTo = toContainer.addColors(colorsToMove);

    // Create new container list with updates
    final newContainers = containers.map((container) {
      if (container.id == fromId) return updatedFrom;
      if (container.id == toId) return updatedTo;
      return container; // Unchanged containers stay same
    }).toList();

    // Create move record
    final move = Move.now(
      fromContainerId: fromId,
      toContainerId: toId,
      colorsMoved: amount,
    );

    // Return NEW state
    return GameState(
      containers: newContainers,
      moveHistory: [...moveHistory, move],
      level: level,
    );
  }

  /// Undo the last move and return new state
  ///
  /// HOW UNDO WORKS:
  /// 1. Get last move from history
  /// 2. Reverse the operation:
  ///    - Move colors back from TO to FROM
  ///    - Remove move from history
  /// 3. Return new state
  ///
  /// IMPORTANT: This is NOT just "revert to previous state object"
  /// We don't store full state snapshots (would use too much memory)
  /// Instead, we reconstruct by reversing the operation
  ///
  /// OPTIMIZATION OPPORTUNITY:
  /// For even better undo, could store state snapshots:
  /// ```dart
  /// final List<GameState> stateHistory;
  /// GameState undo() => stateHistory[stateHistory.length - 2];
  /// ```
  /// Trade-off: More memory but simpler logic
  ///
  /// CURRENT APPROACH: Memory efficient, slightly more complex
  GameState undo() {
    if (!canUndo) {
      throw StateError('No moves to undo');
    }

    // Get last move
    final lastMove = moveHistory.last;

    // Find containers (note: reversed from and to!)
    final fromContainer = getContainer(lastMove.toContainerId)!;
    final toContainer = getContainer(lastMove.fromContainerId)!;

    // Get colors to move back
    final colorsToMoveBack = fromContainer.colors
        .sublist(fromContainer.colors.length - lastMove.colorsMoved);

    // Create new containers (reverse the move)
    final updatedFrom = fromContainer.removeTopColors(lastMove.colorsMoved);
    final updatedTo = toContainer.addColors(colorsToMoveBack);

    // Create new container list with updates
    final newContainers = containers.map((container) {
      if (container.id == lastMove.toContainerId) return updatedFrom;
      if (container.id == lastMove.fromContainerId) return updatedTo;
      return container;
    }).toList();

    // Remove last move from history
    final newHistory = moveHistory.sublist(0, moveHistory.length - 1);

    // Return NEW state
    return GameState(
      containers: newContainers,
      moveHistory: newHistory,
      level: level,
    );
  }

  /// Reset to initial state
  ///
  /// Simply creates new state from level
  /// All progress lost (move history cleared)
  GameState reset() {
    return GameState.fromLevel(level);
  }

  // ==================== IMMUTABLE COPY ====================

  /// Create a copy with modifications
  ///
  /// Standard pattern for immutable updates
  /// Rarely needed in game (use applyMove/undo instead)
  /// But useful for testing or special cases
  GameState copyWith({
    List<Container>? containers,
    List<Move>? moveHistory,
    Level? level,
  }) {
    return GameState(
      containers: containers ?? this.containers,
      moveHistory: moveHistory ?? this.moveHistory,
      level: level ?? this.level,
    );
  }

  // ==================== EQUALITY & DEBUGGING ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameState) return false;

    // Check level
    if (level != other.level) return false;

    // Check containers
    if (containers.length != other.containers.length) return false;
    for (int i = 0; i < containers.length; i++) {
      if (containers[i] != other.containers[i]) return false;
    }

    // Check move history
    if (moveHistory.length != other.moveHistory.length) return false;
    for (int i = 0; i < moveHistory.length; i++) {
      if (moveHistory[i] != other.moveHistory[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    level,
    Object.hashAll(containers),
    Object.hashAll(moveHistory),
  );

  @override
  String toString() {
    return 'GameState(level: ${level.id}, moves: $moveCount, won: $isWon, lost: $isLost)';
  }

  /// Detailed debug representation
  String toDebugString() {
    final buffer = StringBuffer();
    buffer.writeln('GameState {');
    buffer.writeln('  Level: ${level.name} (${level.id})');
    buffer.writeln('  Moves: $moveCount / ${level.moveLimit ?? "unlimited"}');
    buffer.writeln('  Status: ${isWon ? "WON" : isLost ? "LOST" : "IN PROGRESS"}');
    buffer.writeln('  Containers:');
    for (final container in containers) {
      buffer.writeln('    ${container.toDebugString()}');
    }
    if (moveHistory.isNotEmpty) {
      buffer.writeln('  Move History:');
      for (int i = 0; i < moveHistory.length; i++) {
        buffer.writeln('    ${i + 1}. ${moveHistory[i]}');
      }
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}
