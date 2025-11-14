# Achievement System Integration Example

## Quick Integration Guide

This guide shows exactly how to integrate the achievement system with your existing GameController.

## Step 1: Update GameState (Optional but Recommended)

Add tracking fields to GameState to monitor hint and undo usage:

```dart
// lib/core/engine/game_state.dart

class GameState {
  // ... existing fields ...

  final bool usedHints;
  final bool usedUndo;

  const GameState({
    // ... existing parameters ...
    this.usedHints = false,
    this.usedUndo = false,
  });

  // Update copyWith method
  GameState copyWith({
    // ... existing parameters ...
    bool? usedHints,
    bool? usedUndo,
  }) {
    return GameState(
      // ... existing fields ...
      usedHints: usedHints ?? this.usedHints,
      usedUndo: usedUndo ?? this.usedUndo,
    );
  }
}
```

## Step 2: Update GameController

Add achievement tracking to the GameController:

```dart
// lib/features/game/controller/game_controller.dart

import '../achievements/controller/achievement_controller.dart';
import '../achievements/widgets/achievement_popup.dart';

class GameController extends StateNotifier<GameState> {
  // ... existing code ...

  // Track if BuildContext is available (for showing popups)
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // Update undo method to track usage
  @override
  void undo() {
    if (!state.canUndo) {
      throw StateError('No moves to undo');
    }

    final newState = state.undo().copyWith(usedUndo: true);
    state = newState;

    _audioService?.playUndo();
    _logUndo();
  }

  // Update _onGameWon to check achievements
  void _onGameWon() async {
    final stars = state.currentStars;
    final moveCount = state.moveCount;

    // Play win sound
    _audioService?.playWin(stars: stars);

    // Save progress first
    // (Assuming you have access to ProgressService via ref or injection)
    // final progressService = ref.read(progressServiceProvider);
    // await progressService.completeLevel(
    //   levelId: state.level.id,
    //   moves: moveCount,
    //   stars: stars,
    // );

    // Check achievements
    await _checkAchievements(stars, moveCount);
  }

  // New method to check and display achievements
  Future<void> _checkAchievements(int stars, int moveCount) async {
    // Skip if no context available
    if (_context == null || !_context!.mounted) return;

    try {
      // Get achievement controller
      // Note: You'll need WidgetRef for this - see Step 3
      final container = ProviderContainer();
      final achievementController = container.read(achievementControllerProvider.notifier);

      // You'll also need access to ProgressService
      // This is a simplified example - adjust based on your DI setup
      final totalLevels = 10; // Get from ProgressService
      final totalStars = 25;  // Get from ProgressService

      // Check achievements
      final newAchievements = await achievementController.onLevelComplete(
        totalLevelsCompleted: totalLevels,
        totalStars: totalStars,
        moveCount: moveCount,
        isPerfect: stars == 3,
        usedHints: state.usedHints,
        themeId: null, // Set if levels have themes
      );

      // Show popup for each new achievement
      for (final achievementId in newAchievements) {
        final achievement = container.read(achievementByIdProvider(achievementId));
        if (achievement != null && _context!.mounted) {
          AchievementPopup.show(_context!, achievement);
          // Wait a bit between popups if multiple achievements
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      container.dispose();
    } catch (e) {
      // Log error but don't crash the game
      print('Error checking achievements: $e');
    }
  }
}
```

## Step 3: Better Integration with WidgetRef

If you prefer cleaner dependency injection, modify GameController to accept WidgetRef:

```dart
// Updated GameController with proper DI

class GameController extends StateNotifier<GameState> {
  final AudioService? _audioService;
  final Ref _ref; // Add Ref for accessing providers

  GameController(
    Level level, {
    AudioService? audioService,
    required Ref ref,
  })  : _audioService = audioService,
        _ref = ref,
        super(GameState.fromLevel(level));

  Future<void> _checkAchievements(int stars, int moveCount, BuildContext context) async {
    if (!context.mounted) return;

    try {
      // Access services via ref
      final achievementController = _ref.read(achievementControllerProvider.notifier);
      final progressService = _ref.read(progressServiceProvider);

      final totalLevels = progressService.getCompletedCount();
      final totalStars = progressService.getTotalStars();

      final newAchievements = await achievementController.onLevelComplete(
        totalLevelsCompleted: totalLevels,
        totalStars: totalStars,
        moveCount: moveCount,
        isPerfect: stars == 3,
        usedHints: state.usedHints,
        themeId: null,
      );

      // Show popups
      for (final achievementId in newAchievements) {
        final achievement = _ref.read(achievementByIdProvider(achievementId));
        if (achievement != null && context.mounted) {
          AchievementPopup.show(context, achievement);
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }
}

// Update provider to pass ref
final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  final level = ref.watch(currentLevelProvider);
  final audioService = ref.watch(audioServiceProvider);

  return GameController(
    level,
    audioService: audioService,
    ref: ref, // Pass ref
  );
});
```

## Step 4: Call from GameScreen

In your GameScreen, call the achievement check when level is completed:

```dart
// lib/features/game/presentation/game_screen.dart

class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);

    // Listen for game completion
    ref.listen(isWonProvider, (previous, next) {
      if (next && !previous) {
        // Game was just won
        _onGameWon(context, ref, gameState);
      }
    });

    // ... rest of build method
  }

  Future<void> _onGameWon(BuildContext context, WidgetRef ref, GameState state) async {
    // Show win dialog first
    await showDialog(
      context: context,
      builder: (context) => WinDialog(
        stars: state.currentStars,
        moves: state.moveCount,
      ),
    );

    // Then check achievements (will show popups)
    // This is already handled in GameController._onGameWon()
    // if you followed Step 3
  }
}
```

## Step 5: Initialize Services in Main

Make sure achievement service is initialized on app start:

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // Initialize achievement service
    final achievementService = ref.read(achievementServiceProvider);
    await achievementService.init();

    // Initialize progress service
    final progressService = ref.read(progressServiceProvider);
    await progressService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Puzzle Game Suite',
      routerConfig: router,
    );
  }
}
```

## Step 6: Add Provider for ProgressService

Create a provider for ProgressService if not already exists:

```dart
// lib/core/services/progress_service.dart

// Add at the end of the file:
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});
```

## Alternative: Simple Integration (No WidgetRef in Controller)

If you prefer to keep GameController simple, handle achievements in the UI layer:

```dart
// lib/features/game/presentation/game_screen.dart

class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    ref.listen(isWonProvider, (previous, next) async {
      if (next && !previous) {
        await _handleGameWon(context, ref, gameState);
      }
    });

    // ... rest of build
  }

  Future<void> _handleGameWon(
    BuildContext context,
    WidgetRef ref,
    GameState state,
  ) async {
    // Save progress
    final progressService = ref.read(progressServiceProvider);
    await progressService.completeLevel(
      levelId: state.level.id,
      moves: state.moveCount,
      stars: state.currentStars,
    );

    // Check achievements
    final achievementController = ref.read(achievementControllerProvider.notifier);
    final newAchievements = await achievementController.onLevelComplete(
      totalLevelsCompleted: progressService.getCompletedCount(),
      totalStars: progressService.getTotalStars(),
      moveCount: state.moveCount,
      isPerfect: state.currentStars == 3,
      usedHints: false, // Track this in GameState
      themeId: null, // Add to Level model if needed
    );

    // Show win dialog
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => WinDialog(
          stars: state.currentStars,
          moves: state.moveCount,
        ),
      );
    }

    // Show achievement popups
    for (final achievementId in newAchievements) {
      final achievement = ref.read(achievementByIdProvider(achievementId));
      if (achievement != null && context.mounted) {
        AchievementPopup.show(context, achievement);
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
}
```

## Testing the Integration

1. **Test First Achievement**:
   ```dart
   // Complete one level
   // Should unlock "First Steps" achievement
   ```

2. **Test Progress Tracking**:
   ```dart
   // Complete 10 levels
   // Should unlock "Getting Started"
   // Check progress on "Puzzle Enthusiast"
   ```

3. **Test Popup Display**:
   ```dart
   // Manually unlock an achievement
   final service = ref.read(achievementServiceProvider);
   await service.unlockAchievement('first_steps');
   // Popup should appear
   ```

4. **Test Persistence**:
   ```dart
   // Unlock achievements
   // Restart app
   // Check achievements screen - should still be unlocked
   ```

## Debugging Tips

1. **Check initialization**:
   ```dart
   print('Achievement service initialized');
   final stats = achievementService.getStats();
   print('Total achievements: ${stats.total}');
   ```

2. **Monitor unlock events**:
   ```dart
   final newAchievements = await controller.onLevelComplete(...);
   print('Newly unlocked: $newAchievements');
   ```

3. **Verify persistence**:
   ```dart
   final progress = achievementService.getAllProgress();
   print('Saved progress: ${progress.length} achievements tracked');
   ```

## Summary

Choose your integration approach:

**Option A**: UI-layer integration (recommended for simplicity)
- Keep GameController focused on game logic
- Handle achievements in GameScreen
- Easier to test and maintain

**Option B**: Controller-layer integration
- More centralized logic
- Requires passing context or ref
- Better for complex achievement conditions

Both approaches work - choose based on your architecture preferences!
