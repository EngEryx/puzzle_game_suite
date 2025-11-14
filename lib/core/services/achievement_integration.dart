import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import 'achievement_service.dart';
import 'progress_service.dart';

/// Integration helper for tracking achievements based on game progress
///
/// ARCHITECTURE:
/// This service bridges ProgressService and AchievementService,
/// listening to game events and updating achievements accordingly.
///
/// USAGE:
/// Call from GameController after level completion to check achievements
class AchievementIntegration {
  final AchievementService _achievementService;
  final ProgressService _progressService;

  AchievementIntegration({
    required AchievementService achievementService,
    required ProgressService progressService,
  })  : _achievementService = achievementService,
        _progressService = progressService;

  /// Check and update achievements after level completion
  ///
  /// PARAMETERS:
  /// - levelId: The completed level ID
  /// - stars: Stars earned (0-3)
  /// - moveCount: Number of moves taken
  /// - usedUndo: Whether undo was used
  /// - usedHints: Whether hints were used
  /// - themeId: Theme of the level (optional)
  ///
  /// RETURNS:
  /// - List of newly unlocked achievement IDs
  Future<List<String>> onLevelComplete({
    required String levelId,
    required int stars,
    required int moveCount,
    required bool usedUndo,
    required bool usedHints,
    String? themeId,
  }) async {
    final List<String> newlyUnlocked = [];

    // Get overall progress
    final totalLevelsCompleted = _progressService.getCompletedCount();
    final totalStars = _progressService.getTotalStars();

    // Calculate perfect levels (3 stars)
    final allProgress = _progressService.getAllProgress();
    final perfectCount = allProgress.values.where((p) => p.stars == 3).length;

    // Check time-based achievements
    final now = DateTime.now();
    final isNightOwl = now.hour >= 0 && now.hour < 6;
    final isEarlyBird = now.hour >= 4 && now.hour < 6;

    // Track achievements through service
    final unlocked = await _achievementService.onLevelComplete(
      totalLevelsCompleted: totalLevelsCompleted,
      totalStars: totalStars,
      moveCount: moveCount,
      isPerfect: stars == 3,
      usedHints: usedHints,
      themeId: themeId,
    );
    newlyUnlocked.addAll(unlocked);

    // Perfect achievements
    if (stars == 3) {
      final perfectUnlocked = await _checkPerfectAchievements(perfectCount);
      newlyUnlocked.addAll(perfectUnlocked);
    }

    // No undo achievement
    if (!usedUndo) {
      final noUndoUnlocked = await _achievementService.unlockAchievement('undo_never');
      if (noUndoUnlocked) {
        newlyUnlocked.add('undo_never');
      }
    }

    // Hint-free achievements
    if (!usedHints) {
      final hintFreeUnlocked = await _checkHintFreeAchievements();
      newlyUnlocked.addAll(hintFreeUnlocked);
    }

    // Time-based achievements
    if (isNightOwl) {
      final nightOwlUnlocked = await _achievementService.unlockAchievement('night_owl');
      if (nightOwlUnlocked) {
        newlyUnlocked.add('night_owl');
      }
    }

    if (isEarlyBird) {
      final earlyBirdUnlocked = await _achievementService.unlockAchievement('early_bird');
      if (earlyBirdUnlocked) {
        newlyUnlocked.add('early_bird');
      }
    }

    // Speed achievements
    if (moveCount <= 10) {
      final speedDemonUnlocked = await _achievementService.unlockAchievement('speed_demon');
      if (speedDemonUnlocked) {
        newlyUnlocked.add('speed_demon');
      }
    }

    if (moveCount <= 5) {
      final lightningUnlocked = await _achievementService.unlockAchievement('lightning_fast');
      if (lightningUnlocked) {
        newlyUnlocked.add('lightning_fast');
      }
    }

    return newlyUnlocked;
  }

  /// Check perfect achievements
  Future<List<String>> _checkPerfectAchievements(int perfectCount) async {
    final List<String> unlocked = [];

    // Perfectionist (5 perfect levels)
    if (perfectCount >= 5) {
      final wasUnlocked = await _achievementService.updateProgress(
        achievementId: 'perfectionist',
        progress: perfectCount,
      );
      if (wasUnlocked) unlocked.add('perfectionist');
    }

    // Flawless Victory (25 perfect levels)
    if (perfectCount >= 25) {
      final wasUnlocked = await _achievementService.updateProgress(
        achievementId: 'flawless_victory',
        progress: perfectCount,
      );
      if (wasUnlocked) unlocked.add('flawless_victory');
    }

    // Absolute Perfection (50 perfect levels)
    if (perfectCount >= 50) {
      final wasUnlocked = await _achievementService.updateProgress(
        achievementId: 'absolute_perfection',
        progress: perfectCount,
      );
      if (wasUnlocked) unlocked.add('absolute_perfection');
    }

    return unlocked;
  }

  /// Check hint-free achievements
  Future<List<String>> _checkHintFreeAchievements() async {
    final List<String> unlocked = [];

    // Track hint-free count (would need to store this in progress service)
    // For now, just increment progress
    final independentUnlocked = await _achievementService.incrementProgress(
      achievementId: 'independent_thinker',
    );
    if (independentUnlocked) unlocked.add('independent_thinker');

    final puristUnlocked = await _achievementService.incrementProgress(
      achievementId: 'purist',
    );
    if (puristUnlocked) unlocked.add('purist');

    return unlocked;
  }

  /// Check achievements on daily login
  Future<List<String>> onDailyLogin() async {
    final List<String> unlocked = [];

    // Track daily login streak
    await _achievementService.onDailyLogin();

    return unlocked;
  }

  /// Check theme completion achievements
  Future<List<String>> checkThemeCompletion(String themeId, int completedCount, int totalCount) async {
    final List<String> unlocked = [];

    if (completedCount >= totalCount) {
      // Theme complete
      switch (themeId) {
        case 'water':
          final wasUnlocked = await _achievementService.unlockAchievement('water_master');
          if (wasUnlocked) unlocked.add('water_master');
          break;
        case 'ball':
          final wasUnlocked = await _achievementService.unlockAchievement('ball_sorter');
          if (wasUnlocked) unlocked.add('ball_sorter');
          break;
        case 'test_tube':
          final wasUnlocked = await _achievementService.unlockAchievement('test_tube_expert');
          if (wasUnlocked) unlocked.add('test_tube_expert');
          break;
      }
    }

    return unlocked;
  }
}

/// Provider for AchievementIntegration
final achievementIntegrationProvider = Provider<AchievementIntegration>((ref) {
  // These would be properly injected in real app
  final achievementService = AchievementService();
  final progressService = ProgressService();

  return AchievementIntegration(
    achievementService: achievementService,
    progressService: progressService,
  );
});
