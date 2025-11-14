import 'container.dart';
import 'move.dart';

/// Validates moves and checks game win conditions.
///
/// KEY CONCEPT: Pure Functions for Game Rules
///
/// This class contains only static methods that are pure functions:
/// - Same inputs always produce same outputs
/// - No side effects (don't modify inputs)
/// - No hidden state or dependencies
///
/// Why pure functions for game rules?
///
/// 1. **Testability**: Easy to unit test
///    ```dart
///    expect(MoveValidator.canMove(from, to), isTrue);
///    ```
///    No setup, no mocks, no state management needed.
///
/// 2. **Predictability**: No surprises
///    The rules don't change based on external state.
///    They work the same way every time.
///
/// 3. **Reusability**: Can use anywhere
///    - Client-side validation (instant feedback)
///    - Server-side validation (prevent cheating)
///    - AI opponent (evaluate moves)
///    - Move hints (find valid moves)
///
/// 4. **Parallelization**: Safe for concurrent use
///    Multiple threads can call these methods simultaneously
///    without race conditions or locks.
///
/// 5. **Caching/Memoization**: Can cache results
///    If inputs are same, output is guaranteed same.
///    Can optimize with memoization if needed.
///
/// Backend Validation Pattern:
///
/// This follows the "validate at the edges" pattern used in backend systems:
///
/// ```
/// Client Request → Validation → Business Logic → Database
///                     ↑
///                 Pure rules
///                 (same on client & server)
/// ```
///
/// Benefits:
/// - Client gets instant feedback (UX)
/// - Server prevents invalid moves (security)
/// - Both use same rules (consistency)
/// - Rules are tested in isolation (quality)
///
/// Performance Implications:
///
/// 1. **Fast**: No I/O, no state lookup, pure computation
///    - canMove(): O(1) - just property checks
///    - isGameWon(): O(n) - iterates containers once
///
/// 2. **No Allocations**: Methods don't create objects
///    - No garbage collection pressure
///    - Can call thousands of times per second
///
/// 3. **CPU Cache Friendly**: Sequential memory access
///    - Container properties are co-located
///    - No pointer chasing through object graphs
///
/// 4. **Optimizable**: Compiler can inline
///    - Static methods can be inlined by Dart compiler
///    - JIT can optimize hot paths
///
/// Example usage:
/// ```dart
/// // Validate before making move
/// if (MoveValidator.canMove(fromContainer, toContainer)) {
///   final move = gameState.makeMove(from, to);
/// }
///
/// // Check win condition
/// if (MoveValidator.isGameWon(gameState.containers)) {
///   showWinScreen();
/// }
/// ```
class MoveValidator {
  // Private constructor - this class should never be instantiated
  // All methods are static utilities
  MoveValidator._();

  /// Check if a move from one container to another is legal.
  ///
  /// Move Rules:
  /// 1. Source container must not be empty
  /// 2. Destination container must not be full
  /// 3. Colors must match OR destination must be empty
  /// 4. Cannot move to same container (from == to)
  ///
  /// Why these rules?
  /// - Rule 1: Can't pour from empty (physically impossible)
  /// - Rule 2: Can't pour into full (no space)
  /// - Rule 3: Only matching colors can stack (game constraint)
  /// - Rule 4: Moving to self is meaningless (no change)
  ///
  /// Parameters:
  /// - [from]: The source container
  /// - [to]: The destination container
  ///
  /// Returns:
  /// - true if the move is legal
  /// - false otherwise
  ///
  /// Time Complexity: O(1) - just property checks
  /// Space Complexity: O(1) - no allocations
  ///
  /// Example:
  /// ```dart
  /// final from = Container.withColors(id: 'A', colors: [red, red]);
  /// final to = Container.withColors(id: 'B', colors: [red, red, red]);
  ///
  /// // Valid: colors match and to isn't full
  /// assert(MoveValidator.canMove(from, to) == true);
  ///
  /// final full = Container.withColors(id: 'C', colors: [blue, blue, blue, blue]);
  /// // Invalid: destination is full
  /// assert(MoveValidator.canMove(from, full) == false);
  /// ```
  static bool canMove(Container from, Container to) {
    // Rule 1: Can't pour from empty container
    if (from.isEmpty) {
      return false;
    }

    // Rule 2: Can't pour into full container
    if (to.isFull) {
      return false;
    }

    // Rule 3: Can't move to same container
    if (from.id == to.id) {
      return false;
    }

    // Rule 4: Colors must match OR destination must be empty
    // If destination is empty, any color can go in
    // If destination has colors, they must match the source top color
    if (!to.isEmpty) {
      final fromColor = from.topColor;
      final toColor = to.topColor;

      if (fromColor != toColor) {
        return false;
      }
    }

    // All rules passed - move is valid
    return true;
  }

  /// Calculate how many colors can be moved from source to destination.
  ///
  /// This determines the actual move count, considering:
  /// 1. How many of the top color are stacked in source
  /// 2. How much space is available in destination
  ///
  /// The actual move count is the minimum of these two values.
  ///
  /// Why minimum?
  /// - Can't move more than we have (source constraint)
  /// - Can't move more than fits (destination constraint)
  ///
  /// Parameters:
  /// - [from]: The source container
  /// - [to]: The destination container
  ///
  /// Returns:
  /// - Number of colors that would be moved (0 if move is invalid)
  ///
  /// Time Complexity: O(n) where n is source container size
  /// - Calls from.topColorCount which iterates from top
  ///
  /// Example:
  /// ```dart
  /// final from = Container.withColors(id: 'A', colors: [red, blue, blue, blue]);
  /// final to = Container.empty(id: 'B', capacity: 4);
  ///
  /// // Has 3 blues stacked, destination has 4 spaces
  /// // Result: min(3, 4) = 3
  /// assert(MoveValidator.getMoveCount(from, to) == 3);
  ///
  /// final smallTo = Container.withColors(id: 'C', colors: [blue, blue]);
  /// // Has 3 blues stacked, destination has 2 spaces (4 capacity - 2 used)
  /// // Result: min(3, 2) = 2
  /// assert(MoveValidator.getMoveCount(from, smallTo) == 2);
  /// ```
  static int getMoveCount(Container from, Container to) {
    // If move isn't valid, count is 0
    if (!canMove(from, to)) {
      return 0;
    }

    // How many of the top color are stacked together
    final sourceCount = from.topColorCount;

    // How much space is available in destination
    final destinationSpace = to.availableSpace;

    // Move the minimum of what we have and what fits
    return sourceCount < destinationSpace ? sourceCount : destinationSpace;
  }

  /// Check if the game is won.
  ///
  /// Win Condition:
  /// - All containers must be "solved"
  /// - A container is solved if:
  ///   * It's empty, OR
  ///   * It's full and contains only one color
  ///
  /// Why this condition?
  /// - Ensures all colors are properly sorted
  /// - Empty containers are okay (may be extra containers)
  /// - Partial containers mean game isn't finished
  ///
  /// Parameters:
  /// - [containers]: All containers in the game
  ///
  /// Returns:
  /// - true if all containers are solved
  /// - false otherwise
  ///
  /// Time Complexity: O(n * m) where:
  /// - n = number of containers
  /// - m = average container size
  /// Each container's isSolved getter may iterate its colors
  ///
  /// Space Complexity: O(1) - no allocations
  ///
  /// Performance note:
  /// This is called after every move, so it needs to be fast.
  /// Fortunately, it's optimized:
  /// 1. Short-circuits on first non-solved container
  /// 2. Container.isSolved is also optimized
  /// 3. No object creation
  ///
  /// Could be optimized further with:
  /// - Caching (track solved containers, only check changed ones)
  /// - Lazy evaluation (only check when needed)
  /// - Incremental updates (maintain solved count)
  ///
  /// But current implementation is simple and fast enough
  /// for typical game sizes (4-12 containers).
  ///
  /// Example:
  /// ```dart
  /// final containers = [
  ///   Container.withColors(id: 'A', colors: [red, red, red, red]),
  ///   Container.withColors(id: 'B', colors: [blue, blue, blue, blue]),
  ///   Container.empty(id: 'C'),
  /// ];
  ///
  /// // All solved: two full with single colors, one empty
  /// assert(MoveValidator.isGameWon(containers) == true);
  ///
  /// final partial = [
  ///   ...containers,
  ///   Container.withColors(id: 'D', colors: [red, blue]), // Mixed!
  /// ];
  ///
  /// // Not solved: container D has mixed colors
  /// assert(MoveValidator.isGameWon(partial) == false);
  /// ```
  static bool isGameWon(List<Container> containers) {
    // Every container must be solved
    // Use .every() which short-circuits on first false
    return containers.every((container) => container.isSolved);
  }

  /// Find all valid moves from a given container.
  ///
  /// This is useful for:
  /// - Hint systems (show player possible moves)
  /// - AI opponents (enumerate options)
  /// - Move validation UI (highlight valid targets)
  ///
  /// Parameters:
  /// - [from]: The source container
  /// - [allContainers]: All containers in the game
  ///
  /// Returns:
  /// - List of containers that are valid destinations
  /// - Empty list if no valid moves
  ///
  /// Time Complexity: O(n) where n = number of containers
  /// Space Complexity: O(n) in worst case (all containers valid)
  ///
  /// Example:
  /// ```dart
  /// final from = Container.withColors(id: 'A', colors: [red, red]);
  /// final containers = [
  ///   from,
  ///   Container.withColors(id: 'B', colors: [red, red, red]), // Valid
  ///   Container.withColors(id: 'C', colors: [blue, blue]), // Invalid (wrong color)
  ///   Container.empty(id: 'D'), // Valid
  ///   Container.withColors(id: 'E', colors: [red, red, red, red]), // Invalid (full)
  /// ];
  ///
  /// final validMoves = MoveValidator.getValidMoves(from, containers);
  /// // Should return containers B and D
  /// assert(validMoves.length == 2);
  /// ```
  static List<Container> getValidMoves(
    Container from,
    List<Container> allContainers,
  ) {
    return allContainers
        .where((to) => canMove(from, to))
        .toList();
  }

  /// Check if any moves are possible in the current game state.
  ///
  /// This is useful for:
  /// - Detecting unwinnable states
  /// - Showing "no moves available" message
  /// - Triggering shuffle/restart prompts
  ///
  /// Parameters:
  /// - [containers]: All containers in the game
  ///
  /// Returns:
  /// - true if at least one valid move exists
  /// - false if no moves are possible
  ///
  /// Time Complexity: O(n²) where n = number of containers
  /// - Worst case: check every pair of containers
  /// - Best case: O(n) if first container has valid move
  ///
  /// Performance note:
  /// Uses nested iteration but short-circuits on first valid move.
  /// For typical game sizes (10-15 containers), this is fast enough.
  ///
  /// Example:
  /// ```dart
  /// final stuck = [
  ///   Container.withColors(id: 'A', colors: [red, red, red, red]),
  ///   Container.withColors(id: 'B', colors: [blue, blue, blue, blue]),
  /// ];
  ///
  /// // All containers full and solved - no moves possible
  /// assert(MoveValidator.hasValidMoves(stuck) == false);
  /// ```
  static bool hasValidMoves(List<Container> containers) {
    // Try each container as source
    for (final from in containers) {
      // Try each other container as destination
      for (final to in containers) {
        if (canMove(from, to)) {
          // Found a valid move - short circuit
          return true;
        }
      }
    }

    // No valid moves found
    return false;
  }
}
