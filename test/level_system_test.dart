import 'package:test/test.dart';
import 'package:puzzle_game_suite/core/models/level.dart';
import 'package:puzzle_game_suite/core/engine/level_validator.dart';
import 'package:puzzle_game_suite/core/engine/level_generator.dart';
import 'package:puzzle_game_suite/data/levels/level_pack.dart';
import 'package:puzzle_game_suite/data/levels/generated_levels.dart';

void main() {
  group('Level Generation System', () {
    test('Generated levels are accessible', () {
      final oceanLevels = GeneratedLevels.oceanLevels;
      expect(oceanLevels, isNotEmpty);
      expect(oceanLevels.first.id, equals('ocean_001'));
    });

    test('Level pack can load levels by theme', () {
      final oceanLevels = LevelPack.getLevelsForTheme('Ocean');
      expect(oceanLevels, isNotEmpty);
    });

    test('Level pack can get level by ID', () {
      final level = LevelPack.getLevelById('ocean_001');
      expect(level, isNotNull);
      expect(level!.id, equals('ocean_001'));
    });

    test('Level pack can get level by number', () {
      final level = LevelPack.getLevelByNumber('Ocean', 1);
      expect(level, isNotNull);
      expect(level!.name, equals('Ocean #1'));
    });

    test('Level pack stats are correct', () {
      final stats = LevelPack.getStatistics();
      expect(stats.levelsByTheme.containsKey('Ocean'), isTrue);
      expect(stats.levelsByTheme.containsKey('Forest'), isTrue);
      expect(stats.levelsByTheme.containsKey('Desert'), isTrue);
      expect(stats.levelsByTheme.containsKey('Space'), isTrue);
    });

    test('Level validator can validate a simple level', () {
      final level = GeneratedLevels.oceanLevels.first;
      final validation = LevelValidator.validateLevel(level.initialContainers);

      // Note: Example levels should be solvable
      expect(validation.isSolvable, isTrue);
    });

    test('Level generator can generate a level', () {
      final level = LevelGenerator.generateLevel(
        difficulty: Difficulty.easy,
        levelNumber: 999,
        seed: 12345,
      );

      expect(level.id, isNotEmpty);
      expect(level.difficulty, equals(Difficulty.easy));
      expect(level.initialContainers, isNotEmpty);
    });

    test('Generated level has valid move limit', () {
      final level = GeneratedLevels.oceanLevels.first;

      expect(level.moveLimit, greaterThan(0));
      expect(level.starThresholds, isNotNull);
      expect(level.starThresholds!.length, equals(3));
    });

    test('Level metadata extraction works', () {
      final metadata = LevelPack.getMetadata('ocean_001');

      expect(metadata, isNotNull);
      expect(metadata!.theme, equals('Ocean'));
      expect(metadata.difficulty, equals(Difficulty.easy));
    });

    test('Next level navigation works', () {
      final nextLevel = LevelPack.getNextLevel('ocean_001');

      // May be null if only one level exists in the example
      if (nextLevel != null) {
        expect(nextLevel.id, equals('ocean_002'));
      }
    });

    test('Level difficulty distribution is correct', () {
      final byDifficulty = LevelPack.getLevelsByDifficulty(theme: 'Ocean');

      expect(byDifficulty.keys, contains(Difficulty.easy));
      expect(byDifficulty[Difficulty.easy], isNotEmpty);
    });
  });

  group('Level Validator', () {
    test('Quick check validates simple configuration', () {
      final level = GeneratedLevels.oceanLevels.first;
      final isValid = LevelValidator.quickCheck(level.initialContainers);

      expect(isValid, isTrue);
    });

    test('Difficulty estimation provides reasonable values', () {
      final level = GeneratedLevels.oceanLevels.first;
      final difficulty = LevelValidator.estimateDifficulty(level.initialContainers);

      expect(difficulty, greaterThan(0));
      expect(difficulty, lessThan(100)); // Reasonable range
    });
  });
}
