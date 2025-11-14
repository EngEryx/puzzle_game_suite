import 'dart:math';
import '../models/level.dart';
import '../models/game_color.dart';
import 'container.dart';
import 'level_validator.dart';

/// Generates puzzle levels with configurable difficulty.
///
/// ALGORITHM OVERVIEW:
///
/// Level generation uses a "reverse solving" approach:
/// 1. Start with solved state (containers with single colors)
/// 2. Apply random valid moves to shuffle
/// 3. Validate the level is solvable
/// 4. Calculate optimal move count
/// 5. Set appropriate move limits and star thresholds
///
/// Why reverse solving?
/// - Guarantees solvability (we started from solution)
/// - Creates realistic puzzles (moves follow game rules)
/// - Difficulty is controllable (more shuffles = harder)
/// - No dead-end states (every configuration is reachable)
///
/// DIFFICULTY PARAMETERS:
///
/// Easy:
/// - 3-4 containers (2 full, 1-2 empty)
/// - 3 colors
/// - 10-15 moves limit
/// - Low shuffle count (5-8 moves)
///
/// Medium:
/// - 4-5 containers (3 full, 1-2 empty)
/// - 4 colors
/// - 15-20 moves limit
/// - Medium shuffle count (10-15 moves)
///
/// Hard:
/// - 5-6 containers (4 full, 1-2 empty)
/// - 5 colors
/// - 20-30 moves limit
/// - High shuffle count (15-20 moves)
///
/// Expert:
/// - 6-8 containers (5-6 full, 1-2 empty)
/// - 6+ colors
/// - 30-40 moves limit
/// - Very high shuffle count (20-30 moves)
///
/// PERFORMANCE OPTIMIZATION:
///
/// 1. Generation is done offline (bin/generate_levels.dart)
/// 2. Levels are precomputed and stored as constants
/// 3. Runtime only loads from JSON/constants (fast)
/// 4. Validation uses BFS with early termination
/// 5. Failed generations retry with different seed
///
/// BALANCING NOTES:
///
/// 1. Empty Containers:
///    - At least 1 empty container required (player needs workspace)
///    - More empty = easier (more move options)
///    - Expert levels: minimal empty containers
///
/// 2. Color Distribution:
///    - Each color fills exactly one container
///    - Colors distributed evenly across containers
///    - Avoids single-color containers in initial state
///
/// 3. Move Limits:
///    - Based on optimal solution + buffer
///    - Easy: 2x optimal moves
///    - Medium: 1.5x optimal moves
///    - Hard: 1.3x optimal moves
///    - Expert: 1.2x optimal moves
///
/// 4. Star Thresholds:
///    - 3 stars: optimal or near-optimal
///    - 2 stars: within 20% of optimal
///    - 1 star: within 40% of optimal
class LevelGenerator {
  // Private constructor - all methods are static
  LevelGenerator._();

  /// Container capacity (standardized across all levels)
  static const int _containerCapacity = 4;

  /// Random number generator (can be seeded for reproducibility)
  static final Random _random = Random();

  /// Generate a level with specified difficulty.
  ///
  /// Parameters:
  /// - [difficulty]: The difficulty level
  /// - [seed]: Optional random seed for reproducibility
  /// - [levelNumber]: Level number for ID/name generation
  /// - [theme]: Optional theme name (e.g., "Ocean", "Forest")
  ///
  /// Returns a fully validated, solvable level.
  ///
  /// Throws [StateError] if unable to generate valid level after max retries.
  static Level generateLevel({
    required Difficulty difficulty,
    int? seed,
    int levelNumber = 1,
    String? theme,
  }) {
    // Generate level with retries
    int attempts = 0;
    const maxAttempts = 100;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        // Use different seed for each attempt to get different results
        final attemptSeed = seed != null ? (seed + attempts) : null;
        final random = attemptSeed != null ? Random(attemptSeed) : _random;

        // Get difficulty parameters - use deterministic values for this seed
        final params = _getDifficultyParams(difficulty, random);

        // Generate solved state
        final solved = _generateInitialState(
          containerCount: params.containerCount,
          colorCount: params.colorCount,
          random: random,
        );

        // Shuffle by taking colors from full containers and putting in empty
        final containers = _distributePuzzle(solved, params.shuffleCount, random);

        // Quick check before expensive validation
        if (!LevelValidator.quickCheck(containers)) {
          continue;
        }

        // Validate solvability
        final validation = LevelValidator.validateLevel(containers);

        if (!validation.isSolvable) {
          continue; // Try again
        }

        // Skip if already solved
        if (validation.optimalMoveCount == null || validation.optimalMoveCount! == 0) {
          continue; // Already solved, try again
        }

        // Skip if optimal moves is too low (level too easy)
        if (validation.optimalMoveCount! < 2) {
          continue;
        }

        // Calculate move limits and star thresholds
        final optimalMoves = validation.optimalMoveCount!;
        final moveLimit = _calculateMoveLimit(optimalMoves, difficulty);
        final starThresholds = _calculateStarThresholds(optimalMoves);

        // Create level
        return Level(
          id: _generateLevelId(levelNumber, theme),
          name: _generateLevelName(levelNumber, difficulty, theme),
          initialContainers: containers,
          difficulty: difficulty,
          moveLimit: moveLimit,
          starThresholds: starThresholds,
          description: _generateDescription(difficulty, params),
        );
      } catch (e) {
        // Continue to next attempt
        continue;
      }
    }

    throw StateError(
      'Failed to generate valid level after $maxAttempts attempts. '
      'Difficulty: $difficulty, Level: $levelNumber',
    );
  }

  /// Generate multiple levels for a specific difficulty.
  ///
  /// Parameters:
  /// - [difficulty]: The difficulty level
  /// - [count]: Number of levels to generate
  /// - [startNumber]: Starting level number
  /// - [theme]: Optional theme name
  /// - [onProgress]: Optional callback for progress updates
  ///
  /// Returns list of generated levels.
  static List<Level> generateLevels({
    required Difficulty difficulty,
    required int count,
    int startNumber = 1,
    String? theme,
    void Function(int current, int total)? onProgress,
  }) {
    final levels = <Level>[];

    for (int i = 0; i < count; i++) {
      final levelNumber = startNumber + i;

      // Use level number as seed for reproducibility
      final level = generateLevel(
        difficulty: difficulty,
        seed: _generateSeed(difficulty, levelNumber, theme),
        levelNumber: levelNumber,
        theme: theme,
      );

      levels.add(level);

      // Progress callback
      onProgress?.call(i + 1, count);
    }

    return levels;
  }

  /// Generate complete level pack (50 levels per theme).
  ///
  /// Parameters:
  /// - [themes]: List of theme names (e.g., ["Ocean", "Forest", "Desert", "Space"])
  /// - [levelsPerTheme]: Number of levels per theme (default 50)
  /// - [onProgress]: Optional callback for progress updates
  ///
  /// Returns map of theme -> levels.
  static Map<String, List<Level>> generateLevelPack({
    required List<String> themes,
    int levelsPerTheme = 50,
    void Function(String theme, int current, int total)? onProgress,
  }) {
    final pack = <String, List<Level>>{};

    for (final theme in themes) {
      final themeLevels = <Level>[];

      // Distribute levels across difficulties
      final distribution = _getDifficultyDistribution(levelsPerTheme);

      int levelNumber = 1;

      for (final entry in distribution.entries) {
        final difficulty = entry.key;
        final count = entry.value;

        final levels = generateLevels(
          difficulty: difficulty,
          count: count,
          startNumber: levelNumber,
          theme: theme,
          onProgress: (current, total) {
            final overallProgress = levelNumber + current - 1;
            onProgress?.call(theme, overallProgress, levelsPerTheme);
          },
        );

        themeLevels.addAll(levels);
        levelNumber += count;
      }

      pack[theme] = themeLevels;
    }

    return pack;
  }

  // ==================== PRIVATE HELPERS ====================

  /// Get difficulty parameters.
  static _DifficultyParams _getDifficultyParams(Difficulty difficulty, Random random) {
    switch (difficulty) {
      case Difficulty.easy:
        return _DifficultyParams(
          containerCount: 3 + random.nextInt(2), // 3-4
          colorCount: 3,
          shuffleCount: 6 + random.nextInt(5), // 6-10 (increased for better mixing)
          moveMin: 10,
          moveMax: 15,
        );

      case Difficulty.medium:
        return _DifficultyParams(
          containerCount: 4 + random.nextInt(2), // 4-5
          colorCount: 4,
          shuffleCount: 12 + random.nextInt(7), // 12-18
          moveMin: 15,
          moveMax: 20,
        );

      case Difficulty.hard:
        return _DifficultyParams(
          containerCount: 5 + random.nextInt(2), // 5-6
          colorCount: 5,
          shuffleCount: 18 + random.nextInt(9), // 18-26
          moveMin: 20,
          moveMax: 30,
        );

      case Difficulty.expert:
        return _DifficultyParams(
          containerCount: 6 + random.nextInt(2), // 6-7 (reduced from 6-8)
          colorCount: 5 + random.nextInt(2), // 5-6 (reduced from 6-8)
          shuffleCount: 20 + random.nextInt(11), // 20-30 (reduced from 25-40)
          moveMin: 30,
          moveMax: 40,
        );
    }
  }

  /// Generate initial solved state.
  ///
  /// Creates containers where:
  /// - Each color fills exactly one container
  /// - One or two containers are empty (workspace)
  /// - All containers have standard capacity
  static List<Container> _generateInitialState({
    required int containerCount,
    required int colorCount,
    required Random random,
  }) {
    final containers = <Container>[];

    // Get available colors
    final availableColors = List<GameColor>.from(GameColor.values);
    availableColors.shuffle(random);

    // Create solved containers (one color per container)
    for (int i = 0; i < colorCount; i++) {
      final color = availableColors[i];
      containers.add(Container.withColors(
        id: 'c$i',
        colors: List.filled(_containerCapacity, color),
        capacity: _containerCapacity,
      ));
    }

    // Add empty containers for workspace
    final emptyCount = containerCount - colorCount;
    for (int i = 0; i < emptyCount; i++) {
      containers.add(Container.empty(
        id: 'c${colorCount + i}',
        capacity: _containerCapacity,
      ));
    }

    return containers;
  }

  /// Distribute puzzle by mixing colors from solved state.
  ///
  /// Uses reverse solving: start from solved state and apply random valid moves.
  static List<Container> _distributePuzzle(
    List<Container> solvedContainers,
    int shuffleCount,
    Random random,
  ) {
    // Clone containers
    var containers = solvedContainers.map((c) {
      return Container.withColors(
        id: c.id,
        colors: List.from(c.colors),
        capacity: c.capacity,
      );
    }).toList();

    // Apply random valid moves to shuffle
    int successfulMoves = 0;
    int attempts = 0;
    final maxAttempts = shuffleCount * 10; // Allow some failed attempts

    while (successfulMoves < shuffleCount && attempts < maxAttempts) {
      attempts++;

      // Pick two random containers
      final fromIdx = random.nextInt(containers.length);
      final toIdx = random.nextInt(containers.length);

      if (fromIdx == toIdx) continue;

      final from = containers[fromIdx];
      final to = containers[toIdx];

      // Check if move is valid
      if (from.isEmpty) continue;
      if (to.isFull) continue;

      // For shuffling, we want to move colors even if they don't match
      // This creates the puzzle complexity
      final fromTop = from.colors.last;

      // Move 1-2 colors at a time for variety
      final moveCount = random.nextInt(2) + 1;
      final actualMoveCount = moveCount.clamp(1, from.colors.length).clamp(1, to.capacity - to.colors.length);

      if (actualMoveCount == 0) continue;

      // Perform the move
      final colorsToMove = from.colors.sublist(from.colors.length - actualMoveCount);

      // Create new containers
      final newFrom = Container.withColors(
        id: from.id,
        colors: from.colors.sublist(0, from.colors.length - actualMoveCount),
        capacity: from.capacity,
      );

      final newTo = Container.withColors(
        id: to.id,
        colors: [...to.colors, ...colorsToMove],
        capacity: to.capacity,
      );

      // Update containers list
      containers = [
        for (int i = 0; i < containers.length; i++)
          if (i == fromIdx)
            newFrom
          else if (i == toIdx)
            newTo
          else
            containers[i],
      ];

      successfulMoves++;
    }

    return containers;
  }

  /// Calculate move limit based on optimal solution.
  static int _calculateMoveLimit(int optimalMoves, Difficulty difficulty) {
    double multiplier;

    switch (difficulty) {
      case Difficulty.easy:
        multiplier = 2.0; // Very generous
      case Difficulty.medium:
        multiplier = 1.5;
      case Difficulty.hard:
        multiplier = 1.3;
      case Difficulty.expert:
        multiplier = 1.2; // Tight
    }

    return (optimalMoves * multiplier).ceil();
  }

  /// Calculate star thresholds.
  static List<int> _calculateStarThresholds(int optimalMoves) {
    return [
      (optimalMoves * 1.4).ceil(), // 1 star: within 40% of optimal
      (optimalMoves * 1.2).ceil(), // 2 stars: within 20% of optimal
      (optimalMoves * 1.05).ceil(), // 3 stars: near optimal
    ];
  }

  /// Generate level ID.
  static String _generateLevelId(int number, String? theme) {
    final themePrefix = theme?.toLowerCase().replaceAll(' ', '_') ?? 'level';
    return '${themePrefix}_${number.toString().padLeft(3, '0')}';
  }

  /// Generate level name.
  static String _generateLevelName(
    int number,
    Difficulty difficulty,
    String? theme,
  ) {
    final themePrefix = theme != null ? '$theme ' : '';
    return '$themePrefix#$number';
  }

  /// Generate description.
  static String _generateDescription(
    Difficulty difficulty,
    _DifficultyParams params,
  ) {
    return 'Sort ${params.colorCount} colors into ${params.containerCount} containers';
  }

  /// Generate reproducible seed.
  static int _generateSeed(Difficulty difficulty, int levelNumber, String? theme) {
    // Combine theme, difficulty, and level number for unique seed
    final themeHash = theme?.hashCode ?? 0;
    final difficultyValue = difficulty.index;
    final baseSeed = (themeHash * 1000000) + (difficultyValue * 10000) + levelNumber;

    // Special offset for Forest theme to avoid problematic seeds
    if (theme?.toLowerCase() == 'forest') {
      return baseSeed + 50000;
    }

    return baseSeed;
  }

  /// Get difficulty distribution for level pack.
  ///
  /// Distributes levels across difficulties with smooth progression:
  /// - Easy: 20% (early levels)
  /// - Medium: 30% (middle levels)
  /// - Hard: 30% (later levels)
  /// - Expert: 20% (final levels)
  static Map<Difficulty, int> _getDifficultyDistribution(int totalLevels) {
    return {
      Difficulty.easy: (totalLevels * 0.20).round(),
      Difficulty.medium: (totalLevels * 0.30).round(),
      Difficulty.hard: (totalLevels * 0.30).round(),
      Difficulty.expert: (totalLevels * 0.20).round(),
    };
  }
}

/// Internal class for difficulty parameters.
class _DifficultyParams {
  final int containerCount;
  final int colorCount;
  final int shuffleCount;
  final int moveMin;
  final int moveMax;

  _DifficultyParams({
    required this.containerCount,
    required this.colorCount,
    required this.shuffleCount,
    required this.moveMin,
    required this.moveMax,
  });
}

