import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking and persisting player progress
///
/// ARCHITECTURE PATTERN: Repository Pattern
///
/// This service acts as a data repository, abstracting away the storage
/// implementation (SharedPreferences) from the rest of the app.
///
/// BACKEND ANALOGY:
/// - Similar to a DAO (Data Access Object) in Java
/// - Repository pattern in Laravel/Django
/// - Service layer in Node.js/Express
///
/// WHY SHARED_PREFERENCES?
/// - Lightweight key-value storage
/// - Perfect for small amounts of data (player progress)
/// - Fast synchronous reads after initialization
/// - Cross-platform (iOS, Android, Web, Desktop)
///
/// ALTERNATIVES CONSIDERED:
/// - SQLite: Overkill for simple progress tracking
/// - Hive: Good, but adds dependency
/// - Firebase: Requires internet, adds complexity
/// - File I/O: Manual serialization, more error-prone
///
/// DATA STRUCTURE:
/// ```json
/// {
///   "level_1": {"completed": true, "stars": 3, "bestMoves": 12},
///   "level_2": {"completed": true, "stars": 2, "bestMoves": 18},
///   "level_3": {"completed": false, "stars": 0, "bestMoves": null}
/// }
/// ```
class ProgressService {
  static const String _progressKey = 'player_progress';
  static const String _unlockedLevelsKey = 'unlocked_levels';

  /// Cached preferences instance
  late final SharedPreferences _prefs;

  /// In-memory cache of progress data
  /// This prevents repeated JSON parsing on every access
  Map<String, LevelProgress> _progressCache = {};

  /// Set of unlocked level IDs
  Set<String> _unlockedLevels = {};

  /// Initialize the service
  /// MUST be called before using any other methods
  ///
  /// ASYNC INITIALIZATION PATTERN:
  /// 1. Call init() on app startup
  /// 2. Wait for completion
  /// 3. Service is ready to use
  ///
  /// USAGE:
  /// ```dart
  /// final progressService = ProgressService();
  /// await progressService.init();
  /// // Now safe to use
  /// ```
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
    _loadUnlockedLevels();
  }

  // ==================== LOAD / SAVE ====================

  /// Load all progress from storage into memory cache
  Future<void> _loadProgress() async {
    final String? jsonString = _prefs.getString(_progressKey);

    if (jsonString == null || jsonString.isEmpty) {
      _progressCache = {};
      return;
    }

    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _progressCache = decoded.map(
        (key, value) => MapEntry(
          key,
          LevelProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      // Corrupted data - reset to empty
      _progressCache = {};
      await _saveProgress();
    }
  }

  /// Save all progress from memory cache to storage
  Future<void> _saveProgress() async {
    final Map<String, dynamic> toEncode = _progressCache.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    final String jsonString = json.encode(toEncode);
    await _prefs.setString(_progressKey, jsonString);
  }

  /// Load unlocked levels from storage
  void _loadUnlockedLevels() {
    final List<String>? unlocked = _prefs.getStringList(_unlockedLevelsKey);
    _unlockedLevels = unlocked?.toSet() ?? {'ocean_001'}; // First ocean level always unlocked
  }

  /// Save unlocked levels to storage
  Future<void> _saveUnlockedLevels() async {
    await _prefs.setStringList(_unlockedLevelsKey, _unlockedLevels.toList());
  }

  // ==================== PROGRESS TRACKING ====================

  /// Get progress for a specific level
  ///
  /// RETURNS:
  /// - LevelProgress if exists
  /// - null if level not yet played
  LevelProgress? getProgress(String levelId) {
    return _progressCache[levelId];
  }

  /// Get progress for all levels
  ///
  /// RETURNS:
  /// - Map of levelId -> LevelProgress
  Map<String, LevelProgress> getAllProgress() {
    return Map.unmodifiable(_progressCache);
  }

  /// Complete a level with a given number of moves and stars
  ///
  /// LOGIC:
  /// - Only updates if better than previous best
  /// - Stars are the primary metric (moves secondary)
  /// - Automatically unlocks next level
  ///
  /// RETURNS:
  /// - true if this is a new best score
  /// - false if previous score was better
  Future<bool> completeLevel({
    required String levelId,
    required int moves,
    required int stars,
  }) async {
    final existing = _progressCache[levelId];

    bool isNewBest = false;

    if (existing == null) {
      // First time completing
      _progressCache[levelId] = LevelProgress(
        completed: true,
        stars: stars,
        bestMoves: moves,
      );
      isNewBest = true;
    } else {
      // Check if this is better than previous
      if (stars > existing.stars ||
          (stars == existing.stars && moves < (existing.bestMoves ?? double.infinity))) {
        _progressCache[levelId] = LevelProgress(
          completed: true,
          stars: stars,
          bestMoves: moves,
        );
        isNewBest = true;
      }
    }

    if (isNewBest) {
      await _saveProgress();

      // Unlock next level (sequential unlock)
      await _unlockNextLevel(levelId);
    }

    return isNewBest;
  }

  /// Mark a level as attempted but not completed
  ///
  /// Useful for tracking which levels the player has tried
  Future<void> attemptLevel(String levelId) async {
    if (!_progressCache.containsKey(levelId)) {
      _progressCache[levelId] = const LevelProgress(
        completed: false,
        stars: 0,
        bestMoves: null,
      );
      await _saveProgress();
    }
  }

  // ==================== UNLOCK LOGIC ====================

  /// Check if a level is unlocked
  ///
  /// UNLOCK STRATEGIES:
  /// 1. Sequential: Only next level unlocks
  /// 2. Star-based: Unlock based on total stars
  /// 3. All unlocked: For testing/casual mode
  ///
  /// Current implementation: Sequential + level 1 always unlocked
  bool isLevelUnlocked(String levelId) {
    return _unlockedLevels.contains(levelId);
  }

  /// Unlock a specific level
  ///
  /// USE CASES:
  /// - IAP (in-app purchase) to unlock level pack
  /// - Cheat code for testing
  /// - Daily challenge level
  Future<void> unlockLevel(String levelId) async {
    if (!_unlockedLevels.contains(levelId)) {
      _unlockedLevels.add(levelId);
      await _saveUnlockedLevels();
    }
  }

  /// Unlock the next level in sequence
  ///
  /// SEQUENTIAL UNLOCK LOGIC:
  /// - Extract theme and number from ID (e.g., "ocean_001" -> theme="ocean", num=1)
  /// - Increment number (e.g., 2)
  /// - Format as 3-digit number (e.g., "002")
  /// - Unlock next level (e.g., "ocean_002")
  /// - If at end of theme (e.g., ocean_050), unlock first level of next theme
  ///
  /// This handles level IDs in format "theme_NNN"
  Future<void> _unlockNextLevel(String currentLevelId) async {
    final match = RegExp(r'(\w+)_(\d+)').firstMatch(currentLevelId);
    if (match != null) {
      final theme = match.group(1)!;
      final currentNum = int.parse(match.group(2)!);
      final nextNum = currentNum + 1;

      // If within same theme (max 50 levels per theme)
      if (nextNum <= 50) {
        final nextLevelId = '${theme}_${nextNum.toString().padLeft(3, '0')}';
        await unlockLevel(nextLevelId);
      } else {
        // Move to next theme
        final themes = ['ocean', 'forest', 'desert', 'space'];
        final currentThemeIndex = themes.indexOf(theme.toLowerCase());
        if (currentThemeIndex >= 0 && currentThemeIndex < themes.length - 1) {
          final nextTheme = themes[currentThemeIndex + 1];
          final nextLevelId = '${nextTheme}_001';
          await unlockLevel(nextLevelId);
        }
      }
    }
  }

  /// Unlock levels based on total stars earned
  ///
  /// STAR-BASED UNLOCK:
  /// - 0-10 stars: Levels 1-10
  /// - 11-20 stars: Levels 11-20
  /// - etc.
  ///
  /// More engaging than pure sequential unlock
  Future<void> updateUnlocksByStars() async {
    final totalStars = getTotalStars();

    // Unlock 1 level per 3 stars earned
    final levelsToUnlock = (totalStars ~/ 3) + 1;

    for (int i = 1; i <= levelsToUnlock && i <= 200; i++) {
      await unlockLevel('level_$i');
    }
  }

  /// Reset all unlocked levels (except ocean_001)
  Future<void> resetUnlockedLevels() async {
    _unlockedLevels = {'ocean_001'};
    await _saveUnlockedLevels();
  }

  // ==================== STATISTICS ====================

  /// Get total number of stars earned across all levels
  int getTotalStars() {
    return _progressCache.values
        .fold(0, (sum, progress) => sum + progress.stars);
  }

  /// Get total number of completed levels
  int getCompletedCount() {
    return _progressCache.values
        .where((progress) => progress.completed)
        .length;
  }

  /// Get completion percentage
  ///
  /// PARAMETERS:
  /// - totalLevels: Total number of levels in the game (e.g., 200)
  ///
  /// RETURNS:
  /// - Percentage (0.0 to 1.0)
  double getCompletionPercentage(int totalLevels) {
    if (totalLevels == 0) return 0.0;
    return getCompletedCount() / totalLevels;
  }

  /// Get statistics for a difficulty level
  ///
  /// PARAMETERS:
  /// - levelIds: List of level IDs for a specific difficulty
  ///
  /// RETURNS:
  /// - DifficultyStats with completion info
  DifficultyStats getDifficultyStats(List<String> levelIds) {
    int completed = 0;
    int stars = 0;

    for (final levelId in levelIds) {
      final progress = _progressCache[levelId];
      if (progress != null && progress.completed) {
        completed++;
        stars += progress.stars;
      }
    }

    return DifficultyStats(
      total: levelIds.length,
      completed: completed,
      stars: stars,
    );
  }

  // ==================== RESET / CLEAR ====================

  /// Reset progress for a specific level
  Future<void> resetLevel(String levelId) async {
    _progressCache.remove(levelId);
    await _saveProgress();
  }

  /// Reset all progress (dangerous!)
  ///
  /// USE CASES:
  /// - User wants fresh start
  /// - Testing
  /// - Account deletion
  ///
  /// CONFIRMATION REQUIRED in UI before calling this
  Future<void> resetAllProgress() async {
    _progressCache.clear();
    await _saveProgress();
    await resetUnlockedLevels();
  }

  /// Export progress as JSON string
  ///
  /// USE CASES:
  /// - Cloud backup
  /// - Transfer between devices
  /// - Support debugging
  String exportProgress() {
    return json.encode(_progressCache.map(
      (key, value) => MapEntry(key, value.toJson()),
    ));
  }

  /// Import progress from JSON string
  ///
  /// USE CASES:
  /// - Restore from cloud backup
  /// - Transfer from another device
  /// - Import saved game
  ///
  /// RETURNS:
  /// - true if import successful
  /// - false if JSON is invalid
  Future<bool> importProgress(String jsonString) async {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _progressCache = decoded.map(
        (key, value) => MapEntry(
          key,
          LevelProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
      await _saveProgress();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==================== DATA MODELS ====================

/// Progress data for a single level
///
/// IMMUTABLE DATA CLASS:
/// - All fields final
/// - copyWith for modifications
/// - JSON serialization
class LevelProgress {
  final bool completed;
  final int stars; // 0-3
  final int? bestMoves; // null if not completed

  const LevelProgress({
    required this.completed,
    required this.stars,
    required this.bestMoves,
  });

  /// Create from JSON
  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      completed: json['completed'] as bool,
      stars: json['stars'] as int,
      bestMoves: json['bestMoves'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'stars': stars,
      'bestMoves': bestMoves,
    };
  }

  /// Create copy with modifications
  LevelProgress copyWith({
    bool? completed,
    int? stars,
    int? bestMoves,
  }) {
    return LevelProgress(
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
      bestMoves: bestMoves ?? this.bestMoves,
    );
  }

  @override
  String toString() {
    return 'LevelProgress(completed: $completed, stars: $stars, bestMoves: $bestMoves)';
  }
}

/// Statistics for a difficulty level
class DifficultyStats {
  final int total;
  final int completed;
  final int stars;

  const DifficultyStats({
    required this.total,
    required this.completed,
    required this.stars,
  });

  /// Completion percentage (0.0 to 1.0)
  double get percentage => total > 0 ? completed / total : 0.0;

  /// Average stars per completed level
  double get averageStars => completed > 0 ? stars / completed : 0.0;
}
