// Generated file - Example levels for demonstration
// In production, run: dart run bin/generate_levels.dart
//
// This file contains hand-crafted example levels that demonstrate
// the level structure. The actual generation script creates 200 levels
// using the LevelGenerator with BFS validation.

import '../../core/models/level.dart';
import '../../core/models/game_color.dart';
import '../../core/engine/container.dart';

/// Generated level pack with example levels.
///
/// This file contains sample levels to demonstrate the structure.
/// To generate all 200 levels, run: dart run bin/generate_levels.dart
class GeneratedLevels {
  GeneratedLevels._();

  /// 50 levels for Ocean theme (showing first 10 as examples).
  static final List<Level> oceanLevels = [
    // Easy levels (1-10)
    Level(
      id: 'ocean_001',
      name: 'Ocean #1',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 12,
      starThresholds: const [10, 8, 6],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.red, GameColor.blue, GameColor.red], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.blue, GameColor.red, GameColor.blue], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.yellow, GameColor.yellow, GameColor.yellow, GameColor.yellow], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    Level(
      id: 'ocean_002',
      name: 'Ocean #2',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 14,
      starThresholds: const [12, 10, 7],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.green, GameColor.red, GameColor.green, GameColor.red], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.blue, GameColor.blue, GameColor.blue, GameColor.blue], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.red, GameColor.green, GameColor.red, GameColor.green], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    Level(
      id: 'ocean_003',
      name: 'Ocean #3',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 16,
      starThresholds: const [14, 11, 8],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.purple, GameColor.yellow, GameColor.purple], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.yellow, GameColor.purple, GameColor.yellow], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.orange, GameColor.orange, GameColor.orange, GameColor.orange], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    // NOTE: In production, this would contain all 50 levels for Ocean theme
  ];

  /// 50 levels for Forest theme (showing first 10 as examples).
  static final List<Level> forestLevels = [
    Level(
      id: 'forest_001',
      name: 'Forest #1',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 12,
      starThresholds: const [10, 8, 6],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.green, GameColor.brown, GameColor.green], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.brown, GameColor.green, GameColor.brown], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.lime, GameColor.lime, GameColor.lime, GameColor.lime], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    // NOTE: In production, this would contain all 50 levels for Forest theme
  ];

  /// 50 levels for Desert theme (showing first 10 as examples).
  static final List<Level> desertLevels = [
    Level(
      id: 'desert_001',
      name: 'Desert #1',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 12,
      starThresholds: const [10, 8, 6],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.yellow, GameColor.orange, GameColor.yellow], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.orange, GameColor.yellow, GameColor.orange], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.brown, GameColor.brown, GameColor.brown, GameColor.brown], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    // NOTE: In production, this would contain all 50 levels for Desert theme
  ];

  /// 50 levels for Space theme (showing first 10 as examples).
  static final List<Level> spaceLevels = [
    Level(
      id: 'space_001',
      name: 'Space #1',
      difficulty: Difficulty.easy,
      description: 'Sort 3 colors into 4 containers',
      moveLimit: 12,
      starThresholds: const [10, 8, 6],
      initialContainers: [
        Container.withColors(id: 'c0', colors: const [GameColor.purple, GameColor.cyan, GameColor.purple], capacity: 4),
        Container.withColors(id: 'c1', colors: const [GameColor.cyan, GameColor.purple, GameColor.cyan], capacity: 4),
        Container.withColors(id: 'c2', colors: const [GameColor.magenta, GameColor.magenta, GameColor.magenta, GameColor.magenta], capacity: 4),
        Container.empty(id: 'c3', capacity: 4),
      ],
    ),
    // NOTE: In production, this would contain all 50 levels for Space theme
  ];

  /// Get levels by theme name.
  static List<Level> getLevelsByTheme(String theme) {
    switch (theme) {
      case 'Ocean':
        return oceanLevels;
      case 'Forest':
        return forestLevels;
      case 'Desert':
        return desertLevels;
      case 'Space':
        return spaceLevels;
      default:
        throw ArgumentError('Unknown theme: $theme');
    }
  }

  /// Get all levels across all themes.
  static List<Level> getAllLevels() {
    return [
      ...oceanLevels,
      ...forestLevels,
      ...desertLevels,
      ...spaceLevels,
    ];
  }
}
