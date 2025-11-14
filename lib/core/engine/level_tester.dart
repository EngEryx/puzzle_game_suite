import '../../core/models/level.dart';
import 'level_validator.dart';

/// Comprehensive level testing utility.
///
/// Provides batch testing, quality verification, and statistics generation
/// for large sets of levels.
class LevelTester {
  LevelTester._();

  /// Test a single level and return detailed results.
  static LevelTestResult testLevel(Level level) {
    final validation = LevelValidator.validateLevel(level.initialContainers);

    return LevelTestResult(
      level: level,
      isSolvable: validation.isSolvable,
      optimalMoves: validation.optimalMoveCount,
      statesExplored: validation.stateSpaceSize,
      passesQualityChecks: _checkQuality(level, validation),
      errorMessage: validation.errorMessage,
      warningMessage: validation.warningMessage,
    );
  }

  /// Test multiple levels and return aggregate results.
  static BatchTestResult testLevels(
    List<Level> levels, {
    void Function(int current, int total)? onProgress,
  }) {
    final results = <LevelTestResult>[];
    int passed = 0;
    int failed = 0;
    int warnings = 0;

    for (int i = 0; i < levels.length; i++) {
      final result = testLevel(levels[i]);
      results.add(result);

      if (result.isSolvable && result.passesQualityChecks) {
        passed++;
      } else {
        failed++;
      }

      if (result.warningMessage != null) {
        warnings++;
      }

      onProgress?.call(i + 1, levels.length);
    }

    return BatchTestResult(
      totalLevels: levels.length,
      passed: passed,
      failed: failed,
      warnings: warnings,
      results: results,
    );
  }

  /// Generate statistics for a set of levels.
  static LevelStatistics generateStatistics(List<Level> levels) {
    final results = testLevels(levels).results;

    // Difficulty distribution
    final difficultyCount = <Difficulty, int>{};
    for (final level in levels) {
      difficultyCount[level.difficulty] =
          (difficultyCount[level.difficulty] ?? 0) + 1;
    }

    // Container count distribution
    final containerCount = <int, int>{};
    for (final level in levels) {
      final count = level.containerCount;
      containerCount[count] = (containerCount[count] ?? 0) + 1;
    }

    // Optimal moves statistics
    final optimalMoves = results
        .where((r) => r.optimalMoves != null)
        .map((r) => r.optimalMoves!)
        .toList();

    optimalMoves.sort();

    final avgOptimalMoves = optimalMoves.isNotEmpty
        ? optimalMoves.reduce((a, b) => a + b) / optimalMoves.length
        : 0.0;

    final minOptimalMoves =
        optimalMoves.isNotEmpty ? optimalMoves.first : 0;
    final maxOptimalMoves =
        optimalMoves.isNotEmpty ? optimalMoves.last : 0;

    // State space statistics
    final stateSpaces = results
        .where((r) => r.statesExplored != null)
        .map((r) => r.statesExplored!)
        .toList();

    final avgStatesExplored = stateSpaces.isNotEmpty
        ? stateSpaces.reduce((a, b) => a + b) / stateSpaces.length
        : 0.0;

    return LevelStatistics(
      totalLevels: levels.length,
      difficultyDistribution: difficultyCount,
      containerDistribution: containerCount,
      averageOptimalMoves: avgOptimalMoves,
      minOptimalMoves: minOptimalMoves,
      maxOptimalMoves: maxOptimalMoves,
      averageStatesExplored: avgStatesExplored,
      solvableCount: results.where((r) => r.isSolvable).length,
      qualityPassCount: results.where((r) => r.passesQualityChecks).length,
    );
  }

  /// Check if a level passes quality checks.
  static bool _checkQuality(Level level, ValidationResult validation) {
    // Must be solvable
    if (!validation.isSolvable) return false;

    // Must have optimal moves data
    if (validation.optimalMoveCount == null) return false;

    // Optimal moves should be at least 2
    if (validation.optimalMoveCount! < 2) return false;

    // Move limit should be reasonable (not too tight or loose)
    if (level.moveLimit != null) {
      final ratio = level.moveLimit! / validation.optimalMoveCount!;
      if (ratio < 1.1 || ratio > 3.0) return false;
    }

    // Should explore a reasonable number of states
    if (validation.stateSpaceSize != null) {
      if (validation.stateSpaceSize! < 3) return false; // Too trivial
    }

    return true;
  }

  /// Find duplicate levels (same initial configuration).
  static List<DuplicateGroup> findDuplicates(List<Level> levels) {
    final signatures = <String, List<Level>>{};

    for (final level in levels) {
      final signature = _generateSignature(level);
      signatures[signature] = (signatures[signature] ?? [])..add(level);
    }

    return signatures.entries
        .where((entry) => entry.value.length > 1)
        .map((entry) => DuplicateGroup(entry.value))
        .toList();
  }

  /// Generate a signature for a level based on container configuration.
  static String _generateSignature(Level level) {
    final containers = level.initialContainers.map((c) {
      if (c.isEmpty) {
        return 'E';
      } else {
        return c.colors.map((color) => color.name[0]).join('');
      }
    }).toList();

    containers.sort(); // Normalize order
    return containers.join('|');
  }

  /// Verify difficulty progression (harder levels should have more moves).
  static DifficultyProgressionResult verifyDifficultyProgression(
    List<Level> levels,
  ) {
    final byDifficulty = <Difficulty, List<LevelTestResult>>{};

    for (final level in levels) {
      final result = testLevel(level);
      byDifficulty[level.difficulty] = (byDifficulty[level.difficulty] ?? [])
        ..add(result);
    }

    // Calculate average optimal moves per difficulty
    final averages = <Difficulty, double>{};
    for (final entry in byDifficulty.entries) {
      final moves = entry.value
          .where((r) => r.optimalMoves != null)
          .map((r) => r.optimalMoves!)
          .toList();

      if (moves.isNotEmpty) {
        averages[entry.key] = moves.reduce((a, b) => a + b) / moves.length;
      }
    }

    // Check if progression is monotonic
    final difficulties = [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.hard,
      Difficulty.expert,
    ];

    bool isMonotonic = true;
    for (int i = 1; i < difficulties.length; i++) {
      final prev = averages[difficulties[i - 1]] ?? 0;
      final curr = averages[difficulties[i]] ?? 0;

      if (curr < prev) {
        isMonotonic = false;
        break;
      }
    }

    return DifficultyProgressionResult(
      averagesByDifficulty: averages,
      isMonotonic: isMonotonic,
    );
  }
}

/// Result of testing a single level.
class LevelTestResult {
  final Level level;
  final bool isSolvable;
  final int? optimalMoves;
  final int? statesExplored;
  final bool passesQualityChecks;
  final String? errorMessage;
  final String? warningMessage;

  const LevelTestResult({
    required this.level,
    required this.isSolvable,
    this.optimalMoves,
    this.statesExplored,
    required this.passesQualityChecks,
    this.errorMessage,
    this.warningMessage,
  });

  @override
  String toString() {
    return 'LevelTestResult(${level.id}: ${isSolvable ? "PASS" : "FAIL"}, '
        'optimal=$optimalMoves, states=$statesExplored)';
  }
}

/// Result of batch testing multiple levels.
class BatchTestResult {
  final int totalLevels;
  final int passed;
  final int failed;
  final int warnings;
  final List<LevelTestResult> results;

  const BatchTestResult({
    required this.totalLevels,
    required this.passed,
    required this.failed,
    required this.warnings,
    required this.results,
  });

  double get passRate => totalLevels > 0 ? passed / totalLevels : 0.0;

  @override
  String toString() {
    return 'BatchTestResult(\n'
        '  Total: $totalLevels\n'
        '  Passed: $passed (${(passRate * 100).toStringAsFixed(1)}%)\n'
        '  Failed: $failed\n'
        '  Warnings: $warnings\n'
        ')';
  }
}

/// Statistics about a set of levels.
class LevelStatistics {
  final int totalLevels;
  final Map<Difficulty, int> difficultyDistribution;
  final Map<int, int> containerDistribution;
  final double averageOptimalMoves;
  final int minOptimalMoves;
  final int maxOptimalMoves;
  final double averageStatesExplored;
  final int solvableCount;
  final int qualityPassCount;

  const LevelStatistics({
    required this.totalLevels,
    required this.difficultyDistribution,
    required this.containerDistribution,
    required this.averageOptimalMoves,
    required this.minOptimalMoves,
    required this.maxOptimalMoves,
    required this.averageStatesExplored,
    required this.solvableCount,
    required this.qualityPassCount,
  });

  @override
  String toString() {
    return 'LevelStatistics(\n'
        '  Total Levels: $totalLevels\n'
        '  Solvable: $solvableCount\n'
        '  Quality Pass: $qualityPassCount\n'
        '  Difficulty Distribution: $difficultyDistribution\n'
        '  Container Distribution: $containerDistribution\n'
        '  Optimal Moves: avg=${averageOptimalMoves.toStringAsFixed(1)}, '
        'min=$minOptimalMoves, max=$maxOptimalMoves\n'
        '  Avg States Explored: ${averageStatesExplored.toStringAsFixed(1)}\n'
        ')';
  }
}

/// Group of duplicate levels.
class DuplicateGroup {
  final List<Level> levels;

  DuplicateGroup(this.levels);

  @override
  String toString() {
    final ids = levels.map((l) => l.id).join(', ');
    return 'Duplicate: [$ids]';
  }
}

/// Result of difficulty progression verification.
class DifficultyProgressionResult {
  final Map<Difficulty, double> averagesByDifficulty;
  final bool isMonotonic;

  const DifficultyProgressionResult({
    required this.averagesByDifficulty,
    required this.isMonotonic,
  });

  @override
  String toString() {
    return 'DifficultyProgressionResult(\n'
        '  Averages: $averagesByDifficulty\n'
        '  Monotonic: $isMonotonic\n'
        ')';
  }
}
