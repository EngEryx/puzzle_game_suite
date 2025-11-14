import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import 'achievement_definitions.dart';

/// Service for tracking and persisting achievement progress
///
/// ARCHITECTURE PATTERN: Repository Pattern
///
/// This service manages:
/// 1. Achievement progress persistence (SharedPreferences)
/// 2. Unlock logic and validation
/// 3. Progress tracking for incremental achievements
/// 4. Achievement notifications
///
/// BACKEND ANALOGY:
/// - Similar to a DAO (Data Access Object)
/// - Combines repository + business logic
/// - Could be split into AchievementRepository + AchievementService in larger apps
///
/// DATA STRUCTURE:
/// ```json
/// {
///   "first_steps": {
///     "achievementId": "first_steps",
///     "currentProgress": 10,
///     "isUnlocked": true,
///     "unlockedAt": "2024-01-15T10:30:00.000Z",
///     "hasViewed": true
///   },
///   "star_collector_50": {
///     "achievementId": "star_collector_50",
///     "currentProgress": 35,
///     "isUnlocked": false,
///     "unlockedAt": null,
///     "hasViewed": false
///   }
/// }
/// ```
class AchievementService {
  static const String _progressKey = 'achievement_progress';
  static const String _notificationsKey = 'achievement_notifications';

  /// Cached preferences instance
  late final SharedPreferences _prefs;

  /// In-memory cache of progress data
  Map<String, AchievementProgress> _progressCache = {};

  /// Queue of achievements that were recently unlocked (for notifications)
  List<String> _pendingNotifications = [];

  /// All available achievements (from definitions)
  final List<Achievement> _allAchievements = AchievementDefinitions.all;

  // ==================== INITIALIZATION ====================

  /// Initialize the service
  ///
  /// MUST be called before using any other methods
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProgress();
    _loadPendingNotifications();
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
          AchievementProgress.fromJson(value as Map<String, dynamic>),
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

  /// Load pending notifications
  void _loadPendingNotifications() {
    _pendingNotifications = _prefs.getStringList(_notificationsKey) ?? [];
  }

  /// Save pending notifications
  Future<void> _savePendingNotifications() async {
    await _prefs.setStringList(_notificationsKey, _pendingNotifications);
  }

  // ==================== ACHIEVEMENT QUERIES ====================

  /// Get all achievements
  List<Achievement> getAllAchievements() {
    return List.unmodifiable(_allAchievements);
  }

  /// Get achievement by ID
  Achievement? getAchievement(String id) {
    try {
      return _allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _allAchievements.where((a) => a.type == type).toList();
  }

  /// Get achievements by rarity
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return _allAchievements.where((a) => a.rarity == rarity).toList();
  }

  // ==================== PROGRESS QUERIES ====================

  /// Get progress for a specific achievement
  AchievementProgress getProgress(String achievementId) {
    return _progressCache[achievementId] ??
        AchievementProgress(achievementId: achievementId);
  }

  /// Get all achievement progress
  Map<String, AchievementProgress> getAllProgress() {
    return Map.unmodifiable(_progressCache);
  }

  /// Check if achievement is unlocked
  bool isUnlocked(String achievementId) {
    return _progressCache[achievementId]?.isUnlocked ?? false;
  }

  /// Get all unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return _allAchievements
        .where((a) => isUnlocked(a.id))
        .toList();
  }

  /// Get all locked achievements
  List<Achievement> getLockedAchievements({bool includeHidden = false}) {
    return _allAchievements
        .where((a) {
          if (!includeHidden && a.isHidden && !isUnlocked(a.id)) {
            return false;
          }
          return !isUnlocked(a.id);
        })
        .toList();
  }

  // ==================== PROGRESS TRACKING ====================

  /// Update progress for an achievement
  ///
  /// PARAMETERS:
  /// - achievementId: The achievement to update
  /// - progress: New progress value
  /// - autoUnlock: Whether to automatically unlock when maxProgress reached
  ///
  /// RETURNS:
  /// - true if achievement was newly unlocked
  Future<bool> updateProgress({
    required String achievementId,
    required int progress,
    bool autoUnlock = true,
  }) async {
    final achievement = getAchievement(achievementId);
    if (achievement == null) return false;

    final existing = _progressCache[achievementId];
    final currentProgress = existing?.currentProgress ?? 0;

    // Don't decrease progress
    if (progress <= currentProgress) return false;

    // Clamp to max progress
    final newProgress = progress.clamp(0, achievement.maxProgress);

    // Update progress
    _progressCache[achievementId] = AchievementProgress(
      achievementId: achievementId,
      currentProgress: newProgress,
      isUnlocked: existing?.isUnlocked ?? false,
      unlockedAt: existing?.unlockedAt,
      hasViewed: existing?.hasViewed ?? false,
    );

    await _saveProgress();

    // Auto-unlock if reached max progress
    if (autoUnlock && newProgress >= achievement.maxProgress) {
      return await unlockAchievement(achievementId);
    }

    return false;
  }

  /// Increment progress for an achievement
  ///
  /// Convenience method for adding to current progress
  Future<bool> incrementProgress({
    required String achievementId,
    int amount = 1,
  }) async {
    final current = getProgress(achievementId).currentProgress;
    return await updateProgress(
      achievementId: achievementId,
      progress: current + amount,
    );
  }

  /// Unlock an achievement
  ///
  /// RETURNS:
  /// - true if this is a new unlock
  /// - false if already unlocked
  Future<bool> unlockAchievement(String achievementId) async {
    final achievement = getAchievement(achievementId);
    if (achievement == null) return false;

    final existing = _progressCache[achievementId];

    // Already unlocked
    if (existing?.isUnlocked == true) return false;

    // Unlock it
    _progressCache[achievementId] = AchievementProgress(
      achievementId: achievementId,
      currentProgress: achievement.maxProgress,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      hasViewed: false,
    );

    // Add to notification queue
    _pendingNotifications.add(achievementId);

    await _saveProgress();
    await _savePendingNotifications();

    return true;
  }

  /// Mark achievement as viewed
  ///
  /// Used to remove "NEW!" badge after player sees it
  Future<void> markAsViewed(String achievementId) async {
    final existing = _progressCache[achievementId];
    if (existing == null) return;

    _progressCache[achievementId] = existing.copyWith(hasViewed: true);
    await _saveProgress();
  }

  // ==================== NOTIFICATIONS ====================

  /// Get pending achievement notifications
  ///
  /// Returns achievements that were unlocked but not yet shown to player
  List<Achievement> getPendingNotifications() {
    return _pendingNotifications
        .map((id) => getAchievement(id))
        .where((a) => a != null)
        .cast<Achievement>()
        .toList();
  }

  /// Clear a specific notification
  Future<void> clearNotification(String achievementId) async {
    _pendingNotifications.remove(achievementId);
    await _savePendingNotifications();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _pendingNotifications.clear();
    await _savePendingNotifications();
  }

  // ==================== STATISTICS ====================

  /// Get achievement statistics
  AchievementStats getStats() {
    final total = _allAchievements.length;
    final unlocked = getUnlockedAchievements().length;

    final points = _allAchievements
        .where((a) => isUnlocked(a.id))
        .fold(0, (sum, a) => sum + a.points);

    final maxPoints = _allAchievements
        .fold(0, (sum, a) => sum + a.points);

    return AchievementStats(
      total: total,
      unlocked: unlocked,
      points: points,
      maxPoints: maxPoints,
    );
  }

  /// Get stats by type
  Map<AchievementType, AchievementStats> getStatsByType() {
    final Map<AchievementType, AchievementStats> stats = {};

    for (final type in AchievementType.values) {
      final achievements = getAchievementsByType(type);
      final total = achievements.length;
      final unlocked = achievements.where((a) => isUnlocked(a.id)).length;
      final points = achievements
          .where((a) => isUnlocked(a.id))
          .fold(0, (sum, a) => sum + a.points);
      final maxPoints = achievements.fold(0, (sum, a) => sum + a.points);

      stats[type] = AchievementStats(
        total: total,
        unlocked: unlocked,
        points: points,
        maxPoints: maxPoints,
      );
    }

    return stats;
  }

  /// Get recently unlocked achievements (within last 7 days)
  List<Achievement> getRecentlyUnlocked({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _allAchievements.where((achievement) {
      final progress = _progressCache[achievement.id];
      if (progress == null || !progress.isUnlocked) return false;
      if (progress.unlockedAt == null) return false;
      return progress.unlockedAt!.isAfter(cutoff);
    }).toList();
  }

  // ==================== GAME EVENT TRACKING ====================

  /// Track level completion
  ///
  /// Checks and updates relevant achievements
  Future<List<String>> onLevelComplete({
    required int totalLevelsCompleted,
    required int totalStars,
    required int moveCount,
    required bool isPerfect,
    required bool usedHints,
    required String? themeId,
  }) async {
    final List<String> newlyUnlocked = [];

    // Level milestone achievements
    final levelUnlocked = await _checkLevelMilestones(totalLevelsCompleted);
    newlyUnlocked.addAll(levelUnlocked);

    // Star achievements
    final starUnlocked = await _checkStarMilestones(totalStars);
    newlyUnlocked.addAll(starUnlocked);

    // Perfect achievements
    if (isPerfect) {
      // Increment perfect counter (tracked separately in progress service)
      // Could unlock "Perfect Player" achievements
    }

    // Hint-free achievements
    if (!usedHints) {
      // Track hint-free completions
    }

    // Theme-specific achievements
    if (themeId != null) {
      // Track theme completion progress
    }

    return newlyUnlocked;
  }

  /// Check and update level milestone achievements
  Future<List<String>> _checkLevelMilestones(int count) async {
    final List<String> unlocked = [];

    // Check all level-type achievements
    final levelAchievements = getAchievementsByType(AchievementType.level);

    for (final achievement in levelAchievements) {
      final wasUnlocked = await updateProgress(
        achievementId: achievement.id,
        progress: count,
      );
      if (wasUnlocked) {
        unlocked.add(achievement.id);
      }
    }

    return unlocked;
  }

  /// Check and update star milestone achievements
  Future<List<String>> _checkStarMilestones(int count) async {
    final List<String> unlocked = [];

    final starAchievements = getAchievementsByType(AchievementType.star);

    for (final achievement in starAchievements) {
      final wasUnlocked = await updateProgress(
        achievementId: achievement.id,
        progress: count,
      );
      if (wasUnlocked) {
        unlocked.add(achievement.id);
      }
    }

    return unlocked;
  }

  /// Track daily login
  ///
  /// For consecutive day achievements
  Future<void> onDailyLogin() async {
    // Track login streak
    // Would need to store last login date and compare
    // Increment streak or reset if gap > 1 day
  }

  // ==================== RESET / CLEAR ====================

  /// Reset progress for a specific achievement
  Future<void> resetAchievement(String achievementId) async {
    _progressCache.remove(achievementId);
    await _saveProgress();
  }

  /// Reset all achievement progress (dangerous!)
  Future<void> resetAllProgress() async {
    _progressCache.clear();
    _pendingNotifications.clear();
    await _saveProgress();
    await _savePendingNotifications();
  }

  // ==================== EXPORT / IMPORT ====================

  /// Export achievement progress as JSON string
  String exportProgress() {
    return json.encode(_progressCache.map(
      (key, value) => MapEntry(key, value.toJson()),
    ));
  }

  /// Import achievement progress from JSON string
  Future<bool> importProgress(String jsonString) async {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _progressCache = decoded.map(
        (key, value) => MapEntry(
          key,
          AchievementProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
      await _saveProgress();
      return true;
    } catch (e) {
      return false;
    }
  }
}
