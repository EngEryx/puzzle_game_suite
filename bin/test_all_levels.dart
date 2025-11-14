import 'dart:io';
import 'package:puzzle_game_suite/data/levels/generated_levels.dart';
import 'package:puzzle_game_suite/data/levels/level_pack.dart';
import 'package:puzzle_game_suite/core/engine/level_tester.dart';

/// Comprehensive test suite for all generated levels.
void main() {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║           Level Quality Assurance Test Suite              ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  // Get all levels
  final allLevels = GeneratedLevels.getAllLevels();

  print('Total levels to test: ${allLevels.length}');
  print('');

  // 1. Test solvability and quality
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test 1: Solvability & Quality Check                    │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  final batchResult = LevelTester.testLevels(
    allLevels,
    onProgress: (current, total) {
      stdout.write('\r  Testing level $current/$total...');
    },
  );

  print('\n');
  print('Results:');
  print('  Total: ${batchResult.totalLevels}');
  print('  Passed: ${batchResult.passed} (${(batchResult.passRate * 100).toStringAsFixed(1)}%)');
  print('  Failed: ${batchResult.failed}');
  print('  Warnings: ${batchResult.warnings}');
  print('');

  // Show failed levels
  if (batchResult.failed > 0) {
    print('Failed Levels:');
    for (final result in batchResult.results) {
      if (!result.isSolvable || !result.passesQualityChecks) {
        print('  ${result.level.id}: ${result.errorMessage ?? "Quality check failed"}');
      }
    }
    print('');
  }

  // Show warnings
  if (batchResult.warnings > 0) {
    print('Warnings:');
    int count = 0;
    for (final result in batchResult.results) {
      if (result.warningMessage != null) {
        print('  ${result.level.id}: ${result.warningMessage}');
        count++;
        if (count >= 10) {
          print('  ... and ${batchResult.warnings - 10} more');
          break;
        }
      }
    }
    print('');
  }

  // 2. Check for duplicates
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test 2: Duplicate Detection                            │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  final duplicates = LevelTester.findDuplicates(allLevels);

  if (duplicates.isEmpty) {
    print('✓ No duplicate levels found');
  } else {
    print('✗ Found ${duplicates.length} duplicate groups:');
    for (final group in duplicates) {
      print('  $group');
    }
  }
  print('');

  // 3. Verify difficulty progression
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test 3: Difficulty Progression                         │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  final progression = LevelTester.verifyDifficultyProgression(allLevels);

  print('Average optimal moves by difficulty:');
  for (final entry in progression.averagesByDifficulty.entries) {
    print('  ${entry.key.name.padRight(10)}: ${entry.value.toStringAsFixed(1)} moves');
  }
  print('');
  print('Monotonic progression: ${progression.isMonotonic ? "✓ YES" : "✗ NO"}');
  print('');

  // 4. Generate statistics per theme
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test 4: Theme Statistics                               │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  for (final theme in LevelPack.themes) {
    final themeLevels = LevelPack.getLevelsForTheme(theme);
    final stats = LevelTester.generateStatistics(themeLevels);

    print('Theme: $theme');
    print('  Total: ${stats.totalLevels}');
    print('  Solvable: ${stats.solvableCount}');
    print('  Quality Pass: ${stats.qualityPassCount}');
    print('  Avg Optimal Moves: ${stats.averageOptimalMoves.toStringAsFixed(1)}');
    print('  Range: ${stats.minOptimalMoves}-${stats.maxOptimalMoves} moves');
    print('  Difficulty: ${stats.difficultyDistribution}');
    print('');
  }

  // 5. Overall statistics
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test 5: Overall Statistics                             │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  final overallStats = LevelTester.generateStatistics(allLevels);
  print(overallStats);

  // Final summary
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Test Summary                                            │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');

  final allTestsPassed = batchResult.failed == 0 &&
      duplicates.isEmpty &&
      progression.isMonotonic &&
      batchResult.passRate == 1.0;

  if (allTestsPassed) {
    print('✓ ALL TESTS PASSED');
    print('  All 200 levels are solvable and meet quality standards.');
    exit(0);
  } else {
    print('✗ SOME TESTS FAILED');
    print('  Please review the failures above.');
    exit(1);
  }
}
