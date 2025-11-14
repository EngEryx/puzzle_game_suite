import 'dart:io';
import 'package:puzzle_game_suite/core/models/level.dart';
import 'package:puzzle_game_suite/core/engine/level_generator.dart';
import 'package:puzzle_game_suite/core/engine/level_validator.dart';

/// Test script to debug level generation issues.
void main() {
  print('Testing Level Generation...\n');

  // Test easy level generation
  print('Attempting to generate Easy level with seed 1...');

  for (int attempt = 1; attempt <= 10; attempt++) {
    print('\nAttempt $attempt:');

    try {
      final level = LevelGenerator.generateLevel(
        difficulty: Difficulty.easy,
        seed: 1000 + attempt,
        levelNumber: 1,
        theme: 'Test',
      );

      print('✓ SUCCESS!');
      print('  Level: ${level.name}');
      print('  ID: ${level.id}');
      print('  Containers: ${level.containerCount}');
      print('  Move Limit: ${level.moveLimit}');
      print('  Description: ${level.description}');
      print('\n  Initial State:');

      for (int i = 0; i < level.initialContainers.length; i++) {
        final c = level.initialContainers[i];
        if (c.isEmpty) {
          print('    Container $i: [empty]');
        } else {
          final colors = c.colors.map((col) => col.name).join(', ');
          print('    Container $i: [$colors]');
        }
      }

      // Validate it
      final validation = LevelValidator.validateLevel(level.initialContainers);
      print('\n  Validation:');
      print('    Solvable: ${validation.isSolvable}');
      print('    Optimal Moves: ${validation.optimalMoveCount}');
      print('    States Explored: ${validation.stateSpaceSize}');
      if (validation.warningMessage != null) {
        print('    Warning: ${validation.warningMessage}');
      }

      return; // Exit on success

    } catch (e) {
      print('✗ FAILED: $e');
    }
  }

  print('\n\n❌ All 10 attempts failed!');
  exit(1);
}
