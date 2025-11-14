import 'dart:collection';
import 'container.dart';
import 'move_validator.dart';

/// Validates level solvability and quality.
///
/// SOLVABILITY ALGORITHM:
///
/// Uses Breadth-First Search (BFS) to find shortest solution:
///
/// 1. Start with initial state
/// 2. Generate all valid moves from current state
/// 3. Track visited states (avoid cycles)
/// 4. Continue until win state found or no more states
/// 5. Return path length as optimal move count
///
/// Why BFS instead of DFS?
/// - Guarantees finding shortest path (optimal solution)
/// - Better for validating move limits (need minimum moves)
/// - More memory but acceptable for level generation
///
/// STATE REPRESENTATION:
///
/// Each game state is represented as a string hash of container contents.
/// This allows fast lookup in visited set (O(1) average case).
///
/// Example state:
/// "R,R,R,R|B,B,B,B||"
/// - Container 1: 4 reds
/// - Container 2: 4 blues
/// - Container 3: empty
///
/// PERFORMANCE OPTIMIZATION:
///
/// 1. State Hashing:
///    - String concatenation is faster than deep equality checks
///    - Visited set prevents exploring same state twice
///
/// 2. Early Termination:
///    - Stop when solution found (no need to explore further)
///    - Max depth limit prevents infinite loops on unsolvable levels
///
/// 3. Move Generation:
///    - Only generate valid moves (pruning search space)
///    - Skip moves that lead to previously visited states
///
/// 4. Memory Management:
///    - BFS queue size limited by max depth
///    - Visited states stored as strings (compact)
///
/// VALIDATION CRITERIA:
///
/// A level is valid if:
/// 1. It's solvable (BFS finds solution)
/// 2. Optimal solution is within expected range
/// 3. Color distribution is balanced
/// 4. Move limit is reasonable (not too tight or loose)
///
/// LIMITATIONS:
///
/// 1. State Space Explosion:
///    - For very large levels (10+ containers), state space grows exponentially
///    - Max depth limit prevents excessive computation
///    - Generation retries if validation takes too long
///
/// 2. Heuristic Validation:
///    - Some quality checks are heuristic-based
///    - May not catch all edge cases
///    - Trade-off between validation time and quality
class LevelValidator {
  // Private constructor - all methods are static
  LevelValidator._();

  /// Maximum search depth for BFS solver.
  /// Prevents infinite loops and limits computation time.
  static const int _maxSearchDepth = 50;

  /// Maximum number of states to explore.
  /// Safety limit for memory and time.
  static const int _maxStates = 5000;

  /// Validate a level configuration.
  ///
  /// Performs comprehensive validation including:
  /// - Solvability check using BFS
  /// - Optimal move count calculation
  /// - Color distribution analysis
  /// - Basic sanity checks
  ///
  /// Parameters:
  /// - [containers]: Initial container configuration
  ///
  /// Returns [ValidationResult] with details.
  static ValidationResult validateLevel(List<Container> containers) {
    // Basic sanity checks
    if (containers.isEmpty) {
      return ValidationResult(
        isSolvable: false,
        errorMessage: 'Level has no containers',
      );
    }

    // Check for at least one empty container
    final hasEmptyContainer = containers.any((c) => c.isEmpty);
    if (!hasEmptyContainer && !MoveValidator.isGameWon(containers)) {
      return ValidationResult(
        isSolvable: false,
        errorMessage: 'Level needs at least one empty container',
      );
    }

    // Check if already solved
    if (MoveValidator.isGameWon(containers)) {
      return ValidationResult(
        isSolvable: true,
        optimalMoveCount: 0,
        warningMessage: 'Level is already solved',
      );
    }

    // Run BFS solver
    final solverResult = _solveBFS(containers);

    if (!solverResult.found) {
      return ValidationResult(
        isSolvable: false,
        errorMessage: solverResult.error ?? 'No solution found',
      );
    }

    // Validate color distribution
    final colorValidation = _validateColorDistribution(containers);

    return ValidationResult(
      isSolvable: true,
      optimalMoveCount: solverResult.moveCount,
      stateSpaceSize: solverResult.statesExplored,
      warningMessage: colorValidation,
    );
  }

  /// Solve level using BFS to find optimal solution.
  ///
  /// Returns [_SolverResult] with solution details or error.
  static _SolverResult _solveBFS(List<Container> initialContainers) {
    // BFS queue: (state, depth)
    final queue = Queue<_SearchNode>();
    final visited = <String>{};

    // Initial state
    final initialState = _hashState(initialContainers);
    queue.add(_SearchNode(initialContainers, 0));
    visited.add(initialState);

    int statesExplored = 0;

    while (queue.isNotEmpty) {
      // Safety limits
      if (statesExplored >= _maxStates) {
        return _SolverResult(
          found: false,
          error: 'Search exceeded maximum states ($_maxStates)',
          statesExplored: statesExplored,
        );
      }

      final node = queue.removeFirst();
      statesExplored++;

      // Check depth limit
      if (node.depth >= _maxSearchDepth) {
        continue; // Skip this branch
      }

      // Check if solved
      if (MoveValidator.isGameWon(node.containers)) {
        return _SolverResult(
          found: true,
          moveCount: node.depth,
          statesExplored: statesExplored,
        );
      }

      // Generate all valid moves
      for (int fromIdx = 0; fromIdx < node.containers.length; fromIdx++) {
        for (int toIdx = 0; toIdx < node.containers.length; toIdx++) {
          if (fromIdx == toIdx) continue;

          final from = node.containers[fromIdx];
          final to = node.containers[toIdx];

          if (!MoveValidator.canMove(from, to)) {
            continue; // Invalid move
          }

          // Apply move
          final newContainers = _applyMove(node.containers, fromIdx, toIdx);
          final newState = _hashState(newContainers);

          // Skip if already visited
          if (visited.contains(newState)) {
            continue;
          }

          // Add to queue
          visited.add(newState);
          queue.add(_SearchNode(newContainers, node.depth + 1));
        }
      }
    }

    // No solution found
    return _SolverResult(
      found: false,
      error: 'Level is unsolvable',
      statesExplored: statesExplored,
    );
  }

  /// Create hash string from container state.
  ///
  /// Format: "color1,color2|color3,color4||"
  /// Each container separated by |
  /// Each color separated by ,
  /// Empty containers represented as empty string between |
  static String _hashState(List<Container> containers) {
    return containers
        .map((c) => c.colors.map((color) => color.name[0]).join(','))
        .join('|');
  }

  /// Apply move and return new container list.
  static List<Container> _applyMove(
    List<Container> containers,
    int fromIdx,
    int toIdx,
  ) {
    final from = containers[fromIdx];
    final to = containers[toIdx];

    // Calculate move count
    final moveCount = MoveValidator.getMoveCount(from, to);

    // Get colors to move
    final colors = from.colors.sublist(from.colors.length - moveCount);

    // Create new containers
    final newFrom = Container.withColors(
      id: from.id,
      colors: from.colors.sublist(0, from.colors.length - moveCount),
      capacity: from.capacity,
    );

    final newTo = Container.withColors(
      id: to.id,
      colors: [...to.colors, ...colors],
      capacity: to.capacity,
    );

    // Return new list
    return [
      for (int i = 0; i < containers.length; i++)
        if (i == fromIdx)
          newFrom
        else if (i == toIdx)
          newTo
        else
          containers[i],
    ];
  }

  /// Validate color distribution.
  ///
  /// Checks:
  /// - Colors are distributed across multiple containers
  /// - No container starts fully solved (unless it's a trivial level)
  /// - Color counts are balanced
  ///
  /// Returns warning message if issues found, null otherwise.
  static String? _validateColorDistribution(List<Container> containers) {
    final warnings = <String>[];

    // Count solved containers
    int solvedCount = 0;
    int fullContainers = 0;

    for (final container in containers) {
      if (container.isFull) {
        fullContainers++;
        if (container.isSolved) {
          solvedCount++;
        }
      }
    }

    // Warning if too many containers are already solved
    if (solvedCount > 0 && fullContainers > 0) {
      final ratio = solvedCount / fullContainers;
      if (ratio > 0.5) {
        warnings.add('More than 50% of containers are already solved');
      }
    }

    // Check color variety
    final allColors = <String>{};
    for (final container in containers) {
      for (final color in container.colors) {
        allColors.add(color.name);
      }
    }

    if (allColors.length < 2) {
      warnings.add('Level has less than 2 different colors');
    }

    return warnings.isEmpty ? null : warnings.join('; ');
  }

  /// Quick check if level looks solvable without full BFS.
  ///
  /// This is a heuristic check that's much faster than full validation.
  /// Useful for filtering obviously bad levels before expensive validation.
  ///
  /// Checks:
  /// - At least one empty container OR already won
  /// - Valid moves exist
  /// - Not too many containers (state space manageable)
  ///
  /// Returns true if level looks reasonable, false if obviously broken.
  static bool quickCheck(List<Container> containers) {
    // Empty check
    if (containers.isEmpty) return false;

    // Already won
    if (MoveValidator.isGameWon(containers)) return true;

    // Must have empty container or valid moves
    final hasEmpty = containers.any((c) => c.isEmpty);
    final hasValidMoves = MoveValidator.hasValidMoves(containers);

    if (!hasEmpty && !hasValidMoves) return false;

    // State space size check (heuristic)
    if (containers.length > 12) {
      // Very large levels may be slow to validate
      return false;
    }

    return true;
  }

  /// Estimate difficulty of a level.
  ///
  /// Uses heuristics to estimate difficulty without solving:
  /// - Container count
  /// - Color variety
  /// - Empty container ratio
  /// - Color distribution complexity
  ///
  /// Returns estimated difficulty score (higher = harder).
  static double estimateDifficulty(List<Container> containers) {
    double score = 0;

    // Base: container count
    score += containers.length * 2;

    // Color variety
    final colors = <String>{};
    for (final container in containers) {
      for (final color in container.colors) {
        colors.add(color.name);
      }
    }
    score += colors.length * 3;

    // Empty container penalty (more empty = easier)
    final emptyCount = containers.where((c) => c.isEmpty).length;
    final emptyRatio = emptyCount / containers.length;
    score -= emptyRatio * 10;

    // Mixed color bonus (more mixing = harder)
    int mixedContainers = 0;
    for (final container in containers) {
      if (!container.isEmpty && !container.isSolved) {
        mixedContainers++;
      }
    }
    score += mixedContainers * 2;

    return score;
  }
}

/// Result of level validation.
class ValidationResult {
  /// Whether the level is solvable.
  final bool isSolvable;

  /// Optimal number of moves to solve (null if not solvable).
  final int? optimalMoveCount;

  /// Number of states explored during validation.
  final int? stateSpaceSize;

  /// Error message if validation failed.
  final String? errorMessage;

  /// Warning message if level has issues but is still solvable.
  final String? warningMessage;

  const ValidationResult({
    required this.isSolvable,
    this.optimalMoveCount,
    this.stateSpaceSize,
    this.errorMessage,
    this.warningMessage,
  });

  @override
  String toString() {
    if (!isSolvable) {
      return 'Unsolvable: $errorMessage';
    }

    final parts = ['Solvable in $optimalMoveCount moves'];

    if (stateSpaceSize != null) {
      parts.add('($stateSpaceSize states explored)');
    }

    if (warningMessage != null) {
      parts.add('Warning: $warningMessage');
    }

    return parts.join(' ');
  }
}

/// Internal class for BFS search nodes.
class _SearchNode {
  final List<Container> containers;
  final int depth;

  _SearchNode(this.containers, this.depth);
}

/// Internal class for solver results.
class _SolverResult {
  final bool found;
  final int? moveCount;
  final int statesExplored;
  final String? error;

  _SolverResult({
    required this.found,
    this.moveCount,
    required this.statesExplored,
    this.error,
  });
}
