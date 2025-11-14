import 'dart:io';
import 'package:puzzle_game_suite/core/models/level.dart';
import 'package:puzzle_game_suite/core/engine/level_generator.dart';

/// Special script to generate Forest levels with adjusted seed.
void main() {
  print('Generating Forest levels with adjusted seed...\n');

  final forestLevels = <Level>[];
  const theme = 'Forest';
  const levelsPerTheme = 50;

  // Difficulty distribution
  final distribution = {
    Difficulty.easy: 10,
    Difficulty.medium: 15,
    Difficulty.hard: 15,
    Difficulty.expert: 10,
  };

  int levelNumber = 1;
  int generated = 0;
  int failed = 0;

  for (final entry in distribution.entries) {
    final difficulty = entry.key;
    final count = entry.value;

    print('Generating ${difficulty.name} levels ($count)...');

    for (int i = 0; i < count; i++) {
      final currentLevelNum = levelNumber + i;

      // Use a different seed offset for Forest to avoid problematic seeds
      final baseSeed = _generateSeed(difficulty, currentLevelNum, theme);
      final adjustedSeed = baseSeed + 50000; // Offset to get different randomization

      try {
        final level = LevelGenerator.generateLevel(
          difficulty: difficulty,
          seed: adjustedSeed,
          levelNumber: currentLevelNum,
          theme: theme,
        );

        forestLevels.add(level);
        generated++;
        stdout.write('\r  Level $currentLevelNum/50 ');
      } catch (e) {
        print('\n  Failed level $currentLevelNum: $e');
        failed++;
      }
    }

    levelNumber += count;
    print('');
  }

  print('\nGenerated: $generated');
  print('Failed: $failed');

  if (generated == levelsPerTheme) {
    print('\n✓ All Forest levels generated successfully!');
    print('Now run: dart run bin/integrate_forest_levels.dart');
  } else {
    print('\n✗ Some levels failed to generate');
    exit(1);
  }
}

/// Helper to match the seed generation in LevelGenerator
int _generateSeed(Difficulty difficulty, int levelNumber, String? theme) {
  final themeHash = theme?.hashCode ?? 0;
  final difficultyValue = difficulty.index;
  return (themeHash * 1000000) + (difficultyValue * 10000) + levelNumber;
}
