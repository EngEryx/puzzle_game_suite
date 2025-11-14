import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/models/level.dart';
import '../../../core/models/game_color.dart';
import '../../../core/engine/container.dart' as game_engine;

/// Controller for managing level progress using Riverpod
///
/// ARCHITECTURE PATTERN: StateNotifier + Service Layer
///
/// This controller:
/// 1. Wraps ProgressService for UI consumption
/// 2. Manages reactive state updates
/// 3. Provides computed properties (total stars, completion %)
/// 4. Handles level unlock logic
///
/// SEPARATION OF CONCERNS:
/// - ProgressService: Data persistence (how to save/load)
/// - LevelProgressController: Business logic (what to save/load)
/// - UI: Presentation (how to display)
///
/// SIMILAR TO:
/// - ViewModel in MVVM
/// - Presenter in MVP
/// - Controller in MVC
class LevelProgressController extends StateNotifier<ProgressState> {
  final ProgressService _progressService;

  LevelProgressController(this._progressService)
      : super(const ProgressState.loading()) {
    _init();
  }

  /// Initialize controller
  /// Loads progress from storage and updates state
  Future<void> _init() async {
    try {
      await _progressService.init();
      state = ProgressState.loaded(
        progress: _progressService.getAllProgress(),
        totalStars: _progressService.getTotalStars(),
        completedCount: _progressService.getCompletedCount(),
      );
    } catch (e) {
      state = ProgressState.error('Failed to load progress: $e');
    }
  }

  // ==================== PUBLIC API ====================

  /// Complete a level with the given performance
  ///
  /// FLOW:
  /// 1. Save to service
  /// 2. Check if new best
  /// 3. Update state
  /// 4. Return whether it's a new record
  ///
  /// USAGE:
  /// ```dart
  /// final controller = ref.read(levelProgressProvider.notifier);
  /// final isNewBest = await controller.completeLevel(
  ///   levelId: 'level_5',
  ///   moves: 12,
  ///   stars: 3,
  /// );
  /// if (isNewBest) {
  ///   // Show "New Record!" animation
  /// }
  /// ```
  Future<bool> completeLevel({
    required String levelId,
    required int moves,
    required int stars,
  }) async {
    final isNewBest = await _progressService.completeLevel(
      levelId: levelId,
      moves: moves,
      stars: stars,
    );

    // Refresh state after completion
    await _refreshState();

    return isNewBest;
  }

  /// Get progress for a specific level
  ///
  /// RETURNS:
  /// - LevelProgress if level has been played
  /// - null if level never attempted
  LevelProgress? getProgress(String levelId) {
    return state.maybeWhen(
      loaded: (progress, _, __) => progress[levelId],
      orElse: () => null,
    );
  }

  /// Check if a level is unlocked
  ///
  /// UNLOCK LOGIC:
  /// - Level 1 always unlocked
  /// - Completing level N unlocks level N+1
  /// - Can also unlock by total stars (configurable)
  bool isLevelUnlocked(String levelId) {
    return _progressService.isLevelUnlocked(levelId);
  }

  /// Manually unlock a level
  ///
  /// USE CASES:
  /// - Cheat code for testing
  /// - IAP to unlock level pack
  /// - Daily challenge unlock
  Future<void> unlockLevel(String levelId) async {
    await _progressService.unlockLevel(levelId);
    await _refreshState();
  }

  /// Get statistics for a difficulty level
  ///
  /// USAGE:
  /// ```dart
  /// final easyLevels = ['level_1', 'level_2', ...];
  /// final stats = controller.getDifficultyStats(easyLevels);
  /// print('Easy: ${stats.completed}/${stats.total} completed');
  /// ```
  DifficultyStats getDifficultyStats(List<String> levelIds) {
    return _progressService.getDifficultyStats(levelIds);
  }

  /// Reset progress for a specific level
  Future<void> resetLevel(String levelId) async {
    await _progressService.resetLevel(levelId);
    await _refreshState();
  }

  /// Reset all progress (requires confirmation in UI!)
  Future<void> resetAllProgress() async {
    await _progressService.resetAllProgress();
    await _refreshState();
  }

  // ==================== HELPER METHODS ====================

  /// Refresh state from service
  /// Called after any mutation to sync state
  Future<void> _refreshState() async {
    state = ProgressState.loaded(
      progress: _progressService.getAllProgress(),
      totalStars: _progressService.getTotalStars(),
      completedCount: _progressService.getCompletedCount(),
    );
  }
}

// ==================== STATE DEFINITION ====================

/// State for progress tracking
///
/// UNION TYPE PATTERN:
/// - loading: Initial state, data being loaded
/// - loaded: Success state, data available
/// - error: Failure state, error message
///
/// This is similar to:
/// - Result<T, E> in Rust
/// - Either<L, R> in functional programming
/// - NetworkState in Android
///
/// BENEFITS:
/// - Forces handling of all states
/// - Type-safe state access
/// - Easy to display loading/error UI
class ProgressState {
  final ProgressStateType type;
  final Map<String, LevelProgress>? progress;
  final int? totalStars;
  final int? completedCount;
  final String? errorMessage;

  const ProgressState._({
    required this.type,
    this.progress,
    this.totalStars,
    this.completedCount,
    this.errorMessage,
  });

  const ProgressState.loading()
      : type = ProgressStateType.loading,
        progress = null,
        totalStars = null,
        completedCount = null,
        errorMessage = null;

  const ProgressState.loaded({
    required Map<String, LevelProgress> progress,
    required int totalStars,
    required int completedCount,
  })  : type = ProgressStateType.loaded,
        progress = progress,
        totalStars = totalStars,
        completedCount = completedCount,
        errorMessage = null;

  const ProgressState.error(String message)
      : type = ProgressStateType.error,
        progress = null,
        totalStars = null,
        completedCount = null,
        errorMessage = message;

  /// Pattern matching helper
  ///
  /// USAGE:
  /// ```dart
  /// state.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   loaded: (progress, stars, completed) => ProgressDisplay(...),
  ///   error: (message) => ErrorWidget(message),
  /// );
  /// ```
  T when<T>({
    required T Function() loading,
    required T Function(
      Map<String, LevelProgress> progress,
      int totalStars,
      int completedCount,
    ) loaded,
    required T Function(String message) error,
  }) {
    switch (type) {
      case ProgressStateType.loading:
        return loading();
      case ProgressStateType.loaded:
        return loaded(progress!, totalStars!, completedCount!);
      case ProgressStateType.error:
        return error(errorMessage!);
    }
  }

  /// Pattern matching with fallback
  T maybeWhen<T>({
    T Function()? loading,
    T Function(
      Map<String, LevelProgress> progress,
      int totalStars,
      int completedCount,
    )? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    switch (type) {
      case ProgressStateType.loading:
        return loading != null ? loading() : orElse();
      case ProgressStateType.loaded:
        return loaded != null
            ? loaded(progress!, totalStars!, completedCount!)
            : orElse();
      case ProgressStateType.error:
        return error != null ? error(errorMessage!) : orElse();
    }
  }
}

enum ProgressStateType {
  loading,
  loaded,
  error,
}

// ==================== RIVERPOD PROVIDERS ====================

/// Global singleton ProgressService
///
/// SINGLETON PATTERN:
/// - Only one instance across the app
/// - Initialized once on app startup
/// - Shared by all controllers
///
/// LIFECYCLE:
/// - Created on first access
/// - Lives for entire app lifetime
/// - Can be overridden in tests
final progressServiceProvider = Provider<ProgressService>((ref) {
  final service = ProgressService();
  // Note: init() is called by the controller
  return service;
});

/// Progress controller provider
///
/// USAGE IN UI:
/// ```dart
/// // Watch state (rebuilds on change)
/// final state = ref.watch(levelProgressProvider);
///
/// // Read controller (for actions)
/// final controller = ref.read(levelProgressProvider.notifier);
/// await controller.completeLevel(...);
/// ```
final levelProgressProvider =
    StateNotifierProvider<LevelProgressController, ProgressState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return LevelProgressController(service);
});

/// Total stars provider (derived state)
///
/// UI can watch just the total stars without rebuilding on other changes
final totalStarsProvider = Provider<int>((ref) {
  final state = ref.watch(levelProgressProvider);
  return state.maybeWhen(
    loaded: (_, totalStars, __) => totalStars,
    orElse: () => 0,
  );
});

/// Completion count provider (derived state)
final completedLevelsProvider = Provider<int>((ref) {
  final state = ref.watch(levelProgressProvider);
  return state.maybeWhen(
    loaded: (_, __, completedCount) => completedCount,
    orElse: () => 0,
  );
});

/// Completion percentage provider (derived state)
///
/// PARAMETERS:
/// - totalLevels: Total number of levels in game (200)
final completionPercentageProvider = Provider.family<double, int>((ref, totalLevels) {
  final completed = ref.watch(completedLevelsProvider);
  if (totalLevels == 0) return 0.0;
  return completed / totalLevels;
});

/// Provider for checking if a specific level is unlocked
///
/// FAMILY PATTERN:
/// - Creates a provider per level ID
/// - Each instance is cached
/// - Efficient for large level lists
///
/// USAGE:
/// ```dart
/// final isUnlocked = ref.watch(levelUnlockedProvider('level_5'));
/// ```
final levelUnlockedProvider = Provider.family<bool, String>((ref, levelId) {
  final controller = ref.watch(levelProgressProvider.notifier);
  return controller.isLevelUnlocked(levelId);
});

/// Provider for getting progress of a specific level
final levelProgressByIdProvider =
    Provider.family<LevelProgress?, String>((ref, levelId) {
  final state = ref.watch(levelProgressProvider);
  return state.maybeWhen(
    loaded: (progress, _, __) => progress[levelId],
    orElse: () => null,
  );
});

// ==================== LEVEL GENERATION ====================

/// Generate all 200 levels
///
/// LEVEL DESIGN STRATEGY:
/// 1. Levels 1-50: Easy (2-3 colors, 4-6 containers)
/// 2. Levels 51-100: Medium (3-4 colors, 6-8 containers)
/// 3. Levels 101-150: Hard (4-5 colors, 8-10 containers)
/// 4. Levels 151-200: Expert (5+ colors, 10+ containers)
///
/// TODO: In production, these would be:
/// - Loaded from JSON files
/// - Generated algorithmically
/// - Fetched from a server
/// - Created in a level editor
///
/// For now, we'll create a factory that generates procedural levels
List<Level> generateAllLevels() {
  final List<Level> levels = [];

  // Easy levels (1-50)
  for (int i = 1; i <= 50; i++) {
    levels.add(_generateLevel(i, Difficulty.easy));
  }

  // Medium levels (51-100)
  for (int i = 51; i <= 100; i++) {
    levels.add(_generateLevel(i, Difficulty.medium));
  }

  // Hard levels (101-150)
  for (int i = 101; i <= 150; i++) {
    levels.add(_generateLevel(i, Difficulty.hard));
  }

  // Expert levels (151-200)
  for (int i = 151; i <= 200; i++) {
    levels.add(_generateLevel(i, Difficulty.expert));
  }

  return levels;
}

/// Generate a single level with procedural difficulty scaling
Level _generateLevel(int levelNumber, Difficulty difficulty) {
  // Difficulty-based parameters
  final params = _getDifficultyParams(difficulty);

  // For now, return a simple level structure
  // In production, this would use proper procedural generation
  return Level(
    id: 'level_$levelNumber',
    name: 'Level $levelNumber',
    difficulty: difficulty,
    description: '${difficulty.displayName} puzzle with ${params.colors} colors',
    initialContainers: _generateContainers(params),
    moveLimit: params.moveLimit,
    starThresholds: params.starThresholds,
  );
}

/// Get difficulty parameters
_DifficultyParams _getDifficultyParams(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.easy:
      return const _DifficultyParams(
        colors: 3,
        containers: 5,
        capacity: 4,
        moveLimit: 25,
        starThresholds: [20, 15, 12],
      );
    case Difficulty.medium:
      return const _DifficultyParams(
        colors: 4,
        containers: 7,
        capacity: 4,
        moveLimit: 35,
        starThresholds: [30, 23, 18],
      );
    case Difficulty.hard:
      return const _DifficultyParams(
        colors: 5,
        containers: 9,
        capacity: 4,
        moveLimit: 45,
        starThresholds: [40, 30, 22],
      );
    case Difficulty.expert:
      return const _DifficultyParams(
        colors: 6,
        containers: 11,
        capacity: 4,
        moveLimit: 55,
        starThresholds: [50, 37, 28],
      );
  }
}

/// Generate containers for a level
List<game_engine.Container> _generateContainers(_DifficultyParams params) {
  final containers = <game_engine.Container>[];

  // Available colors based on difficulty
  final availableColors = [
    GameColor.red,
    GameColor.blue,
    GameColor.green,
    GameColor.yellow,
    GameColor.purple,
    GameColor.orange,
  ].take(params.colors).toList();

  // Calculate filled containers (leaving 2 empty for helpers)
  final filledContainers = params.containers - 2;

  // Create filled containers with mixed colors
  for (int i = 0; i < filledContainers; i++) {
    final colors = <GameColor>[];

    // Fill each container to capacity with mixed colors
    for (int j = 0; j < params.capacity; j++) {
      // Distribute colors evenly across containers
      final colorIndex = (i + j) % availableColors.length;
      colors.add(availableColors[colorIndex]);
    }

    containers.add(game_engine.Container.withColors(
      id: 'container_$i',
      colors: colors,
      capacity: params.capacity,
    ));
  }

  // Add 2 empty helper containers
  for (int i = filledContainers; i < params.containers; i++) {
    containers.add(game_engine.Container.empty(
      id: 'container_$i',
      capacity: params.capacity,
    ));
  }

  return containers;
}

class _DifficultyParams {
  final int colors;
  final int containers;
  final int capacity;
  final int moveLimit;
  final List<int> starThresholds;

  const _DifficultyParams({
    required this.colors,
    required this.containers,
    required this.capacity,
    required this.moveLimit,
    required this.starThresholds,
  });
}

/// Provider for all levels
final allLevelsProvider = Provider<List<Level>>((ref) {
  return generateAllLevels();
});

/// Provider for a specific level by ID
final levelByIdProvider = Provider.family<Level?, String>((ref, levelId) {
  final levels = ref.watch(allLevelsProvider);
  try {
    return levels.firstWhere((level) => level.id == levelId);
  } catch (e) {
    return null;
  }
});
