import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/engine/container.dart';
import '../../../core/engine/game_state.dart';
import '../../../core/models/level.dart';
import '../../../core/services/audio_service.dart';
import '../../levels/controller/level_progress_controller.dart';

/// Game controller using Riverpod state management.
///
/// ═══════════════════════════════════════════════════════════════════
/// STATE MANAGEMENT ARCHITECTURE: Riverpod + StateNotifier
/// ═══════════════════════════════════════════════════════════════════
///
/// WHAT IS RIVERPOD?
///
/// Riverpod is Flutter's modern state management solution.
/// Think of it as:
/// - Redux for Flutter (but simpler)
/// - Context.Provider in React (but type-safe)
/// - Dependency Injection + State Management combined
///
/// KEY CONCEPTS:
///
/// 1. PROVIDER: A source of state/data
///    - Like a global variable, but safe and testable
///    - Can depend on other providers
///    - Automatically rebuilds dependents when changed
///
/// 2. STATENOTIFIER: A controller for state
///    - Manages state transitions
///    - Emits new states
///    - Similar to Redux reducer + action creators
///
/// 3. CONSUMER: A widget that listens to providers
///    - Rebuilds when provider changes
///    - Similar to Redux connect() or React useSelector()
///
/// ═══════════════════════════════════════════════════════════════════
/// COMPARISON TO OTHER ARCHITECTURES
/// ═══════════════════════════════════════════════════════════════════
///
/// REDUX (React/JavaScript):
/// ```javascript
/// // Redux Store
/// const store = createStore(gameReducer);
///
/// // Redux Action
/// store.dispatch({ type: 'MAKE_MOVE', from: '1', to: '2' });
///
/// // Redux Selector
/// const state = useSelector(state => state.game);
/// ```
///
/// RIVERPOD (Flutter/Dart):
/// ```dart
/// // Riverpod Provider (like Redux store)
/// final gameProvider = StateNotifierProvider<GameController, GameState>(...);
///
/// // Riverpod Action (method on controller)
/// ref.read(gameProvider.notifier).makeMove('1', '2');
///
/// // Riverpod Selector (like useSelector)
/// final state = ref.watch(gameProvider);
/// ```
///
/// BACKEND STATE MACHINES:
/// - Express.js middleware: request → handler → response
/// - Our flow: user action → controller → new state → UI update
///
/// CLEAN ARCHITECTURE:
/// - Use Cases (Interactors): Our controller methods
/// - Entities: Our GameState and Level models
/// - Repositories: (Future: for saving games)
///
/// ═══════════════════════════════════════════════════════════════════
/// WHY THIS PATTERN?
/// ═══════════════════════════════════════════════════════════════════
///
/// 1. SEPARATION OF CONCERNS
///    - UI: Just renders state (dumb widgets)
///    - Controller: Business logic (smart)
///    - Models: Pure data (no logic)
///
/// 2. TESTABILITY
///    - Can test controller without UI
///    - Can test UI with mock controller
///    - Can test models in isolation
///
/// 3. PREDICTABILITY
///    - State changes only through controller
///    - One source of truth
///    - Easy to debug (trace state changes)
///
/// 4. SCALABILITY
///    - Easy to add features (just add methods)
///    - Easy to add persistence (inject repository)
///    - Easy to add undo/redo (already have history)
///
/// ═══════════════════════════════════════════════════════════════════
class GameController extends StateNotifier<GameState> {
  /// Audio service for sound effects
  final AudioService? _audioService;

  /// Progress controller for saving level completion
  final LevelProgressController? _progressController;

  /// Create controller with initial level
  ///
  /// StateNotifier requires initial state
  /// We create it from the level
  GameController(
    Level level, {
    AudioService? audioService,
    LevelProgressController? progressController,
  })  : _audioService = audioService,
        _progressController = progressController,
        super(GameState.fromLevel(level));

  // ==================== PUBLIC API ====================
  // These methods are called by the UI

  /// Make a move from one container to another
  ///
  /// FLOW:
  /// 1. User taps container A, then container B (UI)
  /// 2. UI calls: controller.makeMove('A', 'B')
  /// 3. Controller validates and applies move
  /// 4. Controller updates state (state = newState)
  /// 5. Riverpod notifies all listeners
  /// 6. UI rebuilds with new state
  ///
  /// ERROR HANDLING:
  /// - Invalid moves throw ArgumentError
  /// - UI should catch and show error message
  /// - State remains unchanged on error
  ///
  /// RETURNS:
  /// - true if move was successful
  /// - false if game is already over
  void makeMove(String fromId, String toId) {
    // Don't allow moves if game is over
    if (state.isGameOver) {
      throw StateError('Cannot make moves: game is over');
    }

    // Apply move (this validates and creates new state)
    // If move is invalid, applyMove throws ArgumentError
    try {
      final newState = state.applyMove(
        fromId: fromId,
        toId: toId,
      );

      // Update state (triggers rebuild of all listeners)
      // This is the ONLY place where state changes!
      state = newState;

      // Play move sound
      _audioService?.playMove();

      // Optional: Log move for analytics
      _logMove(fromId, toId, newState);

      // Optional: Check for win/loss and trigger effects
      if (newState.isWon) {
        _onGameWon();
      } else if (newState.isLost) {
        _onGameLost();
      }
    } catch (e) {
      // Play error sound for invalid move
      _audioService?.playError();
      // Re-throw with more context
      throw ArgumentError('Move failed ($fromId → $toId): $e');
    }
  }

  /// Undo the last move
  ///
  /// UNDO MECHANICS:
  /// - Reverses last move operation
  /// - Updates state to previous configuration
  /// - Decrements move counter
  /// - UI automatically updates
  ///
  /// USE CASES:
  /// - User made mistake
  /// - Exploring different strategies
  /// - Learning/tutorial mode
  ///
  /// LIMITATIONS:
  /// - Can't undo if no moves made
  /// - Some games might disable undo (hardcore mode)
  /// - Could add "undo limit" for balance
  void undo() {
    if (!state.canUndo) {
      throw StateError('No moves to undo');
    }

    // Apply undo (creates new state with move reversed)
    final newState = state.undo();
    state = newState;

    // Play undo sound
    _audioService?.playUndo();

    _logUndo();
  }

  /// Reset game to initial state
  ///
  /// WHEN TO USE:
  /// - User gives up and wants fresh start
  /// - Practicing level repeatedly
  /// - After completing level (play again)
  ///
  /// LOSES:
  /// - All move history
  /// - All progress
  ///
  /// KEEPS:
  /// - Same level configuration
  void reset() {
    final newState = state.reset();
    state = newState;

    // Play level start sound
    _audioService?.playLevelStart();

    _logReset();
  }

  /// Load a new level
  ///
  /// USE CASES:
  /// - User selects different level
  /// - Progressing to next level
  /// - Loading saved game
  ///
  /// This completely replaces current state
  void loadLevel(Level level) {
    state = GameState.fromLevel(level);

    // Play level start sound
    _audioService?.playLevelStart();

    _logLevelLoad(level);
  }

  /// Show hint by applying suggested move with animation.
  ///
  /// This method integrates the hint system with the game controller.
  /// When a hint is requested and found, this can optionally apply it
  /// with visual feedback.
  ///
  /// PARAMETERS:
  /// - [fromId]: Source container ID from hint
  /// - [toId]: Target container ID from hint
  /// - [autoApply]: If true, automatically applies the move
  ///                If false, just highlights (default)
  ///
  /// USAGE:
  /// ```dart
  /// // Just highlight hint (no move)
  /// controller.showHint(hint.fromId, hint.toId, autoApply: false);
  ///
  /// // Apply hint move automatically
  /// await controller.showHint(hint.fromId, hint.toId, autoApply: true);
  /// ```
  Future<void> showHint({
    required String fromId,
    required String toId,
    bool autoApply = false,
  }) async {
    if (autoApply) {
      // Apply the hint move
      makeMove(fromId, toId);
      _logHintApplied(fromId, toId);
    } else {
      // Just log that hint was shown
      // Actual highlighting is handled by HintOverlay widget
      _logHintShown(fromId, toId);
    }
  }

  /// Make a move with animation
  ///
  /// This is the animated version of makeMove. It creates an animation
  /// and defers the actual state update until the animation completes.
  ///
  /// FLOW:
  /// 1. Validate move can be made
  /// 2. Create animation data
  /// 3. Start animation (UI handles with PourAnimator)
  /// 4. Wait for animation to complete
  /// 5. Apply actual game state change
  ///
  /// PARAMETERS:
  /// - [fromId]: Source container ID
  /// - [toId]: Target container ID
  /// - [queueIfAnimating]: If true, queues move if animation is active
  /// - [onAnimationComplete]: Callback when animation finishes
  ///
  /// RETURNS:
  /// - Future that completes when move is fully applied
  ///
  /// USAGE:
  /// ```dart
  /// await controller.animateMove(
  ///   fromId: '1',
  ///   toId: '2',
  ///   onAnimationComplete: () => print('Animation done!'),
  /// );
  /// ```
  /// Calculate how many units will be transferred
  int calculateTransferCount(Container from, Container to) {
    int count = from.topColorCount;

    // Limit by available space in target
    final availableSpace = to.capacity - to.colors.length;
    if (count > availableSpace) {
      count = availableSpace;
    }

    return count;
  }

  // ==================== HELPER METHODS ====================
  // These are private implementation details

  /// Check if a move would be valid (without applying it)
  ///
  /// USE CASES:
  /// - UI showing valid target containers
  /// - Hint system
  /// - Tutorial guidance
  ///
  /// RETURNS:
  /// - null if move is valid
  /// - error message if move is invalid
  String? validateMove(String fromId, String toId) {
    final fromContainer = state.getContainer(fromId);
    final toContainer = state.getContainer(toId);

    if (fromContainer == null) return 'Source container not found';
    if (toContainer == null) return 'Target container not found';

    return MoveValidator.validateMove(fromContainer, toContainer);
  }

  /// Get list of valid target containers for a source container
  ///
  /// USE CASES:
  /// - Highlighting valid moves
  /// - Showing hints
  /// - AI/solver
  ///
  /// RETURNS:
  /// - List of container IDs that can receive from source
  List<String> getValidTargets(String fromId) {
    final fromContainer = state.getContainer(fromId);
    if (fromContainer == null) return [];

    return state.containers
        .where((toContainer) =>
            MoveValidator.validateMove(fromContainer, toContainer) == null)
        .map((container) => container.id)
        .toList();
  }

  /// Check if any valid moves exist
  ///
  /// USE CASES:
  /// - Detecting stuck states (no valid moves = unsolvable)
  /// - Showing "you're stuck" message
  /// - Puzzle validation (level designer tool)
  ///
  /// RETURNS:
  /// - true if at least one valid move exists
  bool hasValidMoves() {
    for (final from in state.containers) {
      for (final to in state.containers) {
        if (MoveValidator.validateMove(from, to) == null) {
          return true;
        }
      }
    }
    return false;
  }

  // ==================== ANALYTICS / LOGGING ====================
  // These would integrate with analytics service

  void _logMove(String fromId, String toId, GameState newState) {
    // Example: Send to Firebase Analytics, Mixpanel, etc.
    // print('Move: $fromId → $toId (${newState.moveCount} total moves)');
  }

  void _logUndo() {
    // print('Undo: ${state.moveCount} moves remaining');
  }

  void _logReset() {
    // print('Reset: ${state.level.id}');
  }

  void _logLevelLoad(Level level) {
    // print('Loaded level: ${level.id}');
  }

  void _logError(String message) {
    // print('ERROR: $message');
    // Could integrate with error tracking service
  }

  void _logHintShown(String fromId, String toId) {
    // Track hint display in analytics
    // print('Hint shown: $fromId → $toId');
  }

  void _logHintApplied(String fromId, String toId) {
    // Track hint application in analytics
    // print('Hint applied: $fromId → $toId');
  }

  // ==================== GAME EVENTS ====================
  // These could trigger effects (sounds, animations, achievements)

  void _onGameWon() {
    // Could trigger:
    // - Victory animation
    // - Sound effect
    // - Achievement unlock
    // - Stats save
    // - Show next level button

    final stars = state.currentStars;

    // Play win sound with appropriate star level
    _audioService?.playWin(stars: stars);

    // Save level progress and unlock next level
    _progressController?.completeLevel(
      levelId: state.level.id,
      moves: state.moveCount,
      stars: stars,
    );

    // print('🎉 Won! Stars: $stars, Moves: ${state.moveCount}');
  }

  void _onGameLost() {
    // Could trigger:
    // - Failure animation
    // - Encouraging message
    // - Hint offer
    // - Retry button

    // Play error sound (gentle, not punishing)
    _audioService?.playError();

    // print('😢 Lost! Move limit: ${state.level.moveLimit}');
  }
}

// ═══════════════════════════════════════════════════════════════════
// RIVERPOD PROVIDER DEFINITIONS
// ═══════════════════════════════════════════════════════════════════
//
// These are the "glue" that connects controller to UI
// Think of them as dependency injection configuration

/// Provider for the current game state and controller
///
/// USAGE IN UI:
/// ```dart
/// class GameScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Read current state
///     final state = ref.watch(gameProvider);
///
///     // Get controller for actions
///     final controller = ref.read(gameProvider.notifier);
///
///     return Column(
///       children: [
///         Text('Moves: ${state.moveCount}'),
///         ElevatedButton(
///           onPressed: () => controller.makeMove('1', '2'),
///           child: Text('Make Move'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// LIFECYCLE:
/// - Created on first access
/// - Stays alive until app closes (or provider disposed)
/// - Can be overridden in tests
///
/// DEPENDENCIES:
/// - Depends on levelProvider (current level)
/// - Could depend on settingsProvider (for undo limit, etc.)
final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  // Get current level (dependency)
  final level = ref.watch(currentLevelProvider);

  // Get audio service (dependency)
  final audioService = ref.watch(audioServiceProvider);

  // Get progress controller (dependency)
  final progressController = ref.watch(levelProgressProvider.notifier);

  // Create controller with level, audio service, and progress controller
  return GameController(
    level,
    audioService: audioService,
    progressController: progressController,
  );
});

/// Provider for the current level
///
/// This is separate from game state because:
/// - Level is selected before game starts
/// - Multiple games can use same level
/// - Level selection UI needs this without creating game
///
/// USAGE:
/// ```dart
/// // Level selection screen
/// final level = ref.watch(currentLevelProvider);
///
/// // Change level
/// ref.read(currentLevelProvider.notifier).state = newLevel;
/// ```
///
/// TODO: In real app, this might come from:
/// - Level repository (database)
/// - Progress tracker (last played level)
/// - Deep link (shared level)
final currentLevelProvider = StateProvider<Level>((ref) {
  // Default to the first level
  final level = ref.watch(levelByIdProvider('level_1'));
  return level ?? Level.tutorial(id: 'tutorial_fallback');
});

/// Provider for move count (derived state)
///
/// This is a COMPUTED value, not stored state
/// Similar to:
/// - SQL view
/// - React useMemo
/// - Vue computed property
///
/// WHY SEPARATE PROVIDER?
/// - UI can watch just the move count
/// - Doesn't rebuild when other state changes
/// - More granular control over rebuilds
///
/// USAGE:
/// ```dart
/// // Only rebuilds when move count changes, not on every state change
/// final moveCount = ref.watch(moveCountProvider);
/// ```
final moveCountProvider = Provider<int>((ref) {
  final state = ref.watch(gameProvider);
  return state.moveCount;
});

/// Provider for win status (derived state)
///
/// Similar pattern to moveCountProvider
/// Allows UI to watch just win condition
final isWonProvider = Provider<bool>((ref) {
  final state = ref.watch(gameProvider);
  return state.isWon;
});

/// Provider for game over status (derived state)
final isGameOverProvider = Provider<bool>((ref) {
  final state = ref.watch(gameProvider);
  return state.isGameOver;
});

/// Provider for can undo status (derived state)
///
/// Useful for enabling/disabling undo button
final canUndoProvider = Provider<bool>((ref) {
  final state = ref.watch(gameProvider);
  return state.canUndo;
});

// ═══════════════════════════════════════════════════════════════════
// ADVANCED PROVIDERS (Optional, for future features)
// ═══════════════════════════════════════════════════════════════════

/// Provider family for container by ID
///
/// FAMILY PATTERN:
/// - Creates provider per parameter
/// - Each instance is cached
/// - Useful for list items
///
/// USAGE:
/// ```dart
/// // In list of containers
/// ListView.builder(
///   itemBuilder: (context, index) {
///     final container = ref.watch(
///       containerByIdProvider(containerId)
///     );
///     return ContainerWidget(container);
///   },
/// )
/// ```
///
/// PERFORMANCE:
/// - Only rebuilds specific container widget
/// - Rest of list stays unchanged
final containerByIdProvider = Provider.family<Container?, String>((ref, id) {
  final state = ref.watch(gameProvider);
  return state.getContainer(id);
});

/// Provider for valid target containers for a source
///
/// USAGE:
/// ```dart
/// // When user selects container to pour from
/// final validTargets = ref.watch(validTargetsProvider(selectedId));
///
/// // Highlight valid target containers in UI
/// for (final targetId in validTargets) {
///   // Show highlight
/// }
/// ```
final validTargetsProvider = Provider.family<List<String>, String>((ref, fromId) {
  final controller = ref.read(gameProvider.notifier);
  return controller.getValidTargets(fromId);
});

/// Provider for current star rating
///
/// Shows live star count as user plays
final currentStarsProvider = Provider<int>((ref) {
  final state = ref.watch(gameProvider);
  return state.currentStars;
});

// ═══════════════════════════════════════════════════════════════════
// TESTING UTILITIES
// ═══════════════════════════════════════════════════════════════════

/// Override provider for testing
///
/// USAGE IN TESTS:
/// ```dart
/// testWidgets('Test game screen', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         // Use mock level for testing
///         currentLevelProvider.overrideWithValue(
///           StateController(mockLevel),
///         ),
///       ],
///       child: GameScreen(),
///     ),
///   );
///
///   // Test UI with mock data
/// });
/// ```

// ═══════════════════════════════════════════════════════════════════
// ARCHITECTURE SUMMARY
// ═══════════════════════════════════════════════════════════════════
//
// DATA FLOW:
// 1. User taps UI
// 2. UI calls controller method via ref.read()
// 3. Controller updates state
// 4. Riverpod notifies listeners
// 5. UI rebuilds via ref.watch()
//
// UNIDIRECTIONAL FLOW:
// User Action → Controller → State Update → UI Update
//
// Similar to:
// - Redux: Action → Reducer → Store → View
// - Flux: Action → Dispatcher → Store → View
// - MVI: Intent → Model → View
//
// BENEFITS:
// - Predictable state changes
// - Easy to debug (trace the flow)
// - Easy to test (mock at any layer)
// - Easy to add features (add provider/method)
//
// ═══════════════════════════════════════════════════════════════════
