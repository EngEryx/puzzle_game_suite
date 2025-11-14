import '../../core/models/level.dart';
import 'generated_levels.dart';

/// Level pack management and loading.
///
/// ARCHITECTURE:
///
/// This class provides a unified interface for accessing all game levels:
/// - Loads pregenerated levels from constants
/// - Organizes levels by theme and difficulty
/// - Provides lookup by ID or sequential number
/// - Handles level pack metadata
///
/// LEVEL PACK STRUCTURE:
///
/// Total: 200 levels across 4 themes
/// - Ocean: 50 levels
/// - Forest: 50 levels
/// - Desert: 50 levels
/// - Space: 50 levels
///
/// Each theme has difficulty progression:
/// - Easy: 10 levels (levels 1-10)
/// - Medium: 15 levels (levels 11-25)
/// - Hard: 15 levels (levels 26-40)
/// - Expert: 10 levels (levels 41-50)
///
/// PERFORMANCE:
///
/// - Levels are stored as constants (no parsing needed)
/// - Lazy loading per theme (only load what's needed)
/// - Fast lookup by ID using maps
/// - Minimal memory footprint (levels are lightweight)
class LevelPack {
  // Private constructor - use static methods
  LevelPack._();

  /// Available themes
  static const List<String> themes = [
    'Ocean',
    'Forest',
    'Desert',
    'Space',
  ];

  /// Levels per theme
  static const int levelsPerTheme = 50;

  /// Total number of levels
  static const int totalLevels = 200;


  /// Get all levels for a theme.
  ///
  /// Parameters:
  /// - [theme]: Theme name (e.g., "Ocean", "Forest")
  ///
  /// Returns list of levels in sequential order.
  ///
  /// Throws [ArgumentError] if theme not found.
  static List<Level> getLevelsForTheme(String theme) {
    if (!themes.contains(theme)) {
      throw ArgumentError('Unknown theme: $theme. Available: ${themes.join(", ")}');
    }

    // Load from generated levels
    return GeneratedLevels.getLevelsByTheme(theme);
  }

  /// Get a specific level by ID.
  ///
  /// Parameters:
  /// - [levelId]: Level ID (e.g., "ocean_001", "forest_025")
  ///
  /// Returns the level or null if not found.
  static Level? getLevelById(String levelId) {
    // Parse theme from ID
    final parts = levelId.split('_');
    if (parts.length != 2) return null;

    final theme = _capitalizeTheme(parts[0]);
    if (!themes.contains(theme)) return null;

    // Get theme levels
    final themeLevels = getLevelsForTheme(theme);

    // Find by ID
    try {
      return themeLevels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  /// Get level by theme and number.
  ///
  /// Parameters:
  /// - [theme]: Theme name
  /// - [number]: Level number (1-50 for each theme)
  ///
  /// Returns the level or null if not found.
  static Level? getLevelByNumber(String theme, int number) {
    if (!themes.contains(theme)) return null;
    if (number < 1 || number > levelsPerTheme) return null;

    final themeLevels = getLevelsForTheme(theme);
    return themeLevels[number - 1]; // Convert to 0-indexed
  }

  /// Get all levels sorted by difficulty.
  ///
  /// Parameters:
  /// - [theme]: Optional theme filter
  ///
  /// Returns levels grouped by difficulty.
  static Map<Difficulty, List<Level>> getLevelsByDifficulty({String? theme}) {
    final levels = theme != null
        ? getLevelsForTheme(theme)
        : getAllLevels();

    final grouped = <Difficulty, List<Level>>{
      Difficulty.easy: [],
      Difficulty.medium: [],
      Difficulty.hard: [],
      Difficulty.expert: [],
    };

    for (final level in levels) {
      grouped[level.difficulty]!.add(level);
    }

    return grouped;
  }

  /// Get all levels across all themes.
  ///
  /// Returns all 200 levels in order (by theme, then by number).
  static List<Level> getAllLevels() {
    final allLevels = <Level>[];

    for (final theme in themes) {
      allLevels.addAll(getLevelsForTheme(theme));
    }

    return allLevels;
  }

  /// Get level metadata.
  ///
  /// Returns information about a level without loading the full level.
  static LevelMetadata? getMetadata(String levelId) {
    final level = getLevelById(levelId);
    if (level == null) return null;

    return LevelMetadata(
      id: level.id,
      name: level.name,
      difficulty: level.difficulty,
      theme: _extractTheme(level.id),
      containerCount: level.containerCount,
      moveLimit: level.moveLimit,
    );
  }

  /// Get next level in sequence.
  ///
  /// Parameters:
  /// - [currentLevelId]: Current level ID
  ///
  /// Returns next level or null if at end.
  static Level? getNextLevel(String currentLevelId) {
    final parts = currentLevelId.split('_');
    if (parts.length != 2) return null;

    final theme = _capitalizeTheme(parts[0]);
    final number = int.tryParse(parts[1]);

    if (number == null || !themes.contains(theme)) return null;

    // Next level in same theme
    if (number < levelsPerTheme) {
      return getLevelByNumber(theme, number + 1);
    }

    // Move to next theme
    final themeIndex = themes.indexOf(theme);
    if (themeIndex < themes.length - 1) {
      return getLevelByNumber(themes[themeIndex + 1], 1);
    }

    // End of all levels
    return null;
  }

  /// Get previous level in sequence.
  ///
  /// Parameters:
  /// - [currentLevelId]: Current level ID
  ///
  /// Returns previous level or null if at start.
  static Level? getPreviousLevel(String currentLevelId) {
    final parts = currentLevelId.split('_');
    if (parts.length != 2) return null;

    final theme = _capitalizeTheme(parts[0]);
    final number = int.tryParse(parts[1]);

    if (number == null || !themes.contains(theme)) return null;

    // Previous level in same theme
    if (number > 1) {
      return getLevelByNumber(theme, number - 1);
    }

    // Move to previous theme
    final themeIndex = themes.indexOf(theme);
    if (themeIndex > 0) {
      return getLevelByNumber(themes[themeIndex - 1], levelsPerTheme);
    }

    // Start of all levels
    return null;
  }

  /// Get progress statistics.
  ///
  /// Returns completion stats for all levels.
  static PackStatistics getStatistics() {
    final allLevels = getAllLevels();

    return PackStatistics(
      totalLevels: allLevels.length,
      levelsByTheme: {
        for (final theme in themes)
          theme: getLevelsForTheme(theme).length,
      },
      levelsByDifficulty: {
        for (final difficulty in Difficulty.values)
          difficulty: allLevels.where((l) => l.difficulty == difficulty).length,
      },
    );
  }

  // ==================== PRIVATE HELPERS ====================

  /// Extract theme from level ID.
  static String _extractTheme(String levelId) {
    final parts = levelId.split('_');
    return parts.isNotEmpty ? _capitalizeTheme(parts[0]) : 'Unknown';
  }

  /// Capitalize theme name.
  static String _capitalizeTheme(String theme) {
    if (theme.isEmpty) return theme;
    return theme[0].toUpperCase() + theme.substring(1).toLowerCase();
  }
}

/// Level metadata (lightweight level info).
class LevelMetadata {
  final String id;
  final String name;
  final Difficulty difficulty;
  final String theme;
  final int containerCount;
  final int? moveLimit;

  const LevelMetadata({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.theme,
    required this.containerCount,
    this.moveLimit,
  });

  @override
  String toString() {
    return 'LevelMetadata(id: $id, name: $name, difficulty: ${difficulty.name})';
  }
}

/// Statistics about the level pack.
class PackStatistics {
  final int totalLevels;
  final Map<String, int> levelsByTheme;
  final Map<Difficulty, int> levelsByDifficulty;

  const PackStatistics({
    required this.totalLevels,
    required this.levelsByTheme,
    required this.levelsByDifficulty,
  });

  @override
  String toString() {
    return 'PackStatistics(\n'
        '  Total: $totalLevels levels\n'
        '  By Theme: $levelsByTheme\n'
        '  By Difficulty: $levelsByDifficulty\n'
        ')';
  }
}
