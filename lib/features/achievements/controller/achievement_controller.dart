import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/achievement.dart';
import '../../../core/services/achievement_service.dart';

/// Achievement state
///
/// Represents the current state of the achievement system
class AchievementState {
  final bool isLoading;
  final List<Achievement> allAchievements;
  final Map<String, AchievementProgress> progress;
  final List<Achievement> pendingNotifications;
  final String? error;

  const AchievementState({
    this.isLoading = true,
    this.allAchievements = const [],
    this.progress = const {},
    this.pendingNotifications = const [],
    this.error,
  });

  AchievementState copyWith({
    bool? isLoading,
    List<Achievement>? allAchievements,
    Map<String, AchievementProgress>? progress,
    List<Achievement>? pendingNotifications,
    String? error,
  }) {
    return AchievementState(
      isLoading: isLoading ?? this.isLoading,
      allAchievements: allAchievements ?? this.allAchievements,
      progress: progress ?? this.progress,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      error: error,
    );
  }
}

/// Achievement controller
///
/// Manages achievement state and business logic
class AchievementController extends StateNotifier<AchievementState> {
  final AchievementService _service;

  AchievementController(this._service) : super(const AchievementState()) {
    _init();
  }

  /// Initialize the controller
  Future<void> _init() async {
    try {
      await _service.init();
      _loadAchievements();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize achievements: $e',
      );
    }
  }

  /// Load all achievements and progress
  void _loadAchievements() {
    try {
      final achievements = _service.getAllAchievements();
      final progress = _service.getAllProgress();
      final notifications = _service.getPendingNotifications();

      state = state.copyWith(
        isLoading: false,
        allAchievements: achievements,
        progress: progress,
        pendingNotifications: notifications,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load achievements: $e',
      );
    }
  }

  /// Refresh achievement data
  Future<void> refresh() async {
    _loadAchievements();
  }

  // ==================== ACHIEVEMENT OPERATIONS ====================

  /// Unlock an achievement
  Future<bool> unlockAchievement(String achievementId) async {
    final wasUnlocked = await _service.unlockAchievement(achievementId);

    if (wasUnlocked) {
      _loadAchievements();
    }

    return wasUnlocked;
  }

  /// Update achievement progress
  Future<bool> updateProgress({
    required String achievementId,
    required int progress,
  }) async {
    final wasUnlocked = await _service.updateProgress(
      achievementId: achievementId,
      progress: progress,
    );

    _loadAchievements();
    return wasUnlocked;
  }

  /// Increment achievement progress
  Future<bool> incrementProgress({
    required String achievementId,
    int amount = 1,
  }) async {
    final wasUnlocked = await _service.incrementProgress(
      achievementId: achievementId,
      amount: amount,
    );

    _loadAchievements();
    return wasUnlocked;
  }

  /// Mark achievement as viewed
  Future<void> markAsViewed(String achievementId) async {
    await _service.markAsViewed(achievementId);
    _loadAchievements();
  }

  // ==================== NOTIFICATIONS ====================

  /// Clear a notification
  Future<void> clearNotification(String achievementId) async {
    await _service.clearNotification(achievementId);
    _loadAchievements();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _service.clearAllNotifications();
    _loadAchievements();
  }

  // ==================== GAME EVENT HANDLERS ====================

  /// Handle level completion
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
    final newlyUnlocked = await _service.onLevelComplete(
      totalLevelsCompleted: totalLevelsCompleted,
      totalStars: totalStars,
      moveCount: moveCount,
      isPerfect: isPerfect,
      usedHints: usedHints,
      themeId: themeId,
    );

    if (newlyUnlocked.isNotEmpty) {
      _loadAchievements();
    }

    return newlyUnlocked;
  }

  // ==================== QUERIES ====================

  /// Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return state.allAchievements
        .where((a) => state.progress[a.id]?.isUnlocked ?? false)
        .toList();
  }

  /// Get locked achievements
  List<Achievement> getLockedAchievements({bool includeHidden = false}) {
    return state.allAchievements.where((a) {
      final progress = state.progress[a.id];
      final isUnlocked = progress?.isUnlocked ?? false;

      if (!includeHidden && a.isHidden && !isUnlocked) {
        return false;
      }

      return !isUnlocked;
    }).toList();
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return state.allAchievements.where((a) => a.type == type).toList();
  }

  /// Get achievements by rarity
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return state.allAchievements.where((a) => a.rarity == rarity).toList();
  }

  /// Get progress for an achievement
  AchievementProgress? getProgress(String achievementId) {
    return state.progress[achievementId];
  }
}

// ==================== RIVERPOD PROVIDERS ====================

/// Provider for AchievementService
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// Provider for AchievementController
final achievementControllerProvider =
    StateNotifierProvider<AchievementController, AchievementState>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return AchievementController(service);
});

/// Provider for achievement stats
final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final state = ref.watch(achievementControllerProvider);

  if (state.isLoading || state.allAchievements.isEmpty) {
    return const AchievementStats(
      total: 0,
      unlocked: 0,
      points: 0,
      maxPoints: 0,
    );
  }

  final total = state.allAchievements.length;
  final unlocked = state.allAchievements
      .where((a) => state.progress[a.id]?.isUnlocked ?? false)
      .length;

  final points = state.allAchievements
      .where((a) => state.progress[a.id]?.isUnlocked ?? false)
      .fold(0, (sum, a) => sum + a.points);

  final maxPoints = state.allAchievements.fold(0, (sum, a) => sum + a.points);

  return AchievementStats(
    total: total,
    unlocked: unlocked,
    points: points,
    maxPoints: maxPoints,
  );
});

/// Provider for unlocked achievements count
final unlockedAchievementsCountProvider = Provider<int>((ref) {
  final stats = ref.watch(achievementStatsProvider);
  return stats.unlocked;
});

/// Provider for pending notifications
final pendingNotificationsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementControllerProvider);
  return state.pendingNotifications;
});

/// Provider for has pending notifications
final hasPendingNotificationsProvider = Provider<bool>((ref) {
  final notifications = ref.watch(pendingNotificationsProvider);
  return notifications.isNotEmpty;
});

/// Provider for recently unlocked achievements
final recentlyUnlockedProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementControllerProvider);

  return state.allAchievements.where((achievement) {
    final progress = state.progress[achievement.id];
    if (progress == null || !progress.isUnlocked) return false;
    return progress.isRecentlyUnlocked;
  }).toList();
});

/// Provider family for achievement by ID
final achievementByIdProvider = Provider.family<Achievement?, String>((ref, id) {
  final state = ref.watch(achievementControllerProvider);
  try {
    return state.allAchievements.firstWhere((a) => a.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider family for achievement progress by ID
final achievementProgressProvider = Provider.family<AchievementProgress?, String>((ref, id) {
  final state = ref.watch(achievementControllerProvider);
  return state.progress[id];
});

/// Provider for achievements grouped by type
final achievementsByTypeProvider = Provider<Map<AchievementType, List<Achievement>>>((ref) {
  final state = ref.watch(achievementControllerProvider);
  final Map<AchievementType, List<Achievement>> grouped = {};

  for (final type in AchievementType.values) {
    grouped[type] = state.allAchievements.where((a) => a.type == type).toList();
  }

  return grouped;
});
