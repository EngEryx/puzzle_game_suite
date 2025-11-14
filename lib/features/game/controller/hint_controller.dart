import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/engine/puzzle_solver.dart';
import '../../../core/engine/container.dart';

/// Hint system controller using Riverpod.
///
/// ═══════════════════════════════════════════════════════════════════
/// HINT SYSTEM: AI-Powered Player Assistance
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Manages hint system state including:
/// - Hint credits/coins
/// - Hint cooldown timers
/// - Hint usage tracking
/// - Hint cost system
/// - Current active hint display
///
/// MONETIZATION INTEGRATION:
///
/// FREE HINTS:
/// - 3 free hints per level
/// - Reset on new level
/// - Cooldown: 30 seconds between hints
///
/// PAID HINTS:
/// - 10 coins per hint after free hints used
/// - No cooldown for paid hints
/// - Integrated with coin system
///
/// HINT ECONOMY DESIGN:
/// - Free hints encourage learning
/// - Paid hints for stuck players
/// - Cooldown prevents spam
/// - Generous enough to not frustrate
/// - Scarce enough to maintain challenge
///
/// STATE MANAGEMENT:
/// Uses Riverpod StateNotifier for reactive state updates
/// Similar to Redux/MobX but Flutter-native
///
/// ═══════════════════════════════════════════════════════════════════
class HintController extends StateNotifier<HintState> {
  HintController() : super(const HintState());

  /// Request a hint for current puzzle state.
  ///
  /// FLOW:
  /// 1. Check if hint available (credits or coins)
  /// 2. Check cooldown timer
  /// 3. Solve puzzle to find next move
  /// 4. Consume hint credit/coins
  /// 5. Start cooldown
  /// 6. Return hint result
  ///
  /// PARAMETERS:
  /// - [containers]: Current puzzle state
  /// - [levelId]: Current level ID (for tracking)
  /// - [useCoins]: If true, use coins instead of free hints
  ///
  /// RETURNS:
  /// - [HintRequestResult] with success/failure and hint data
  Future<HintRequestResult> requestHint({
    required List<Container> containers,
    required String levelId,
    bool useCoins = false,
  }) async {
    // Check if on cooldown
    if (state.isOnCooldown && !useCoins) {
      return HintRequestResult(
        success: false,
        errorMessage: 'Hint on cooldown. Wait ${state.cooldownRemainingSeconds}s',
      );
    }

    // Check if has credits or coins
    if (!useCoins && state.freeHintsRemaining <= 0) {
      return HintRequestResult(
        success: false,
        errorMessage: 'No free hints remaining. Use coins?',
        canUseCoins: true,
      );
    }

    // TODO: Check coin balance if useCoins
    // For now, assume sufficient coins

    // Solve puzzle to find hint
    final hintResult = PuzzleSolver.getNextMove(containers);

    if (!hintResult.found) {
      return HintRequestResult(
        success: false,
        errorMessage: hintResult.errorMessage ?? 'No hint available',
      );
    }

    // Consume hint
    if (useCoins) {
      _consumePaidHint(levelId);
    } else {
      _consumeFreeHint(levelId);
    }

    // Update state with active hint
    state = state.copyWith(
      currentHint: hintResult.move,
      lastHintTime: DateTime.now(),
    );

    return HintRequestResult(
      success: true,
      hint: hintResult.move,
      searchTimeMs: hintResult.searchTimeMs,
      movesToSolution: hintResult.totalMovesToSolution,
    );
  }

  /// Consume a free hint.
  void _consumeFreeHint(String levelId) {
    state = state.copyWith(
      freeHintsRemaining: state.freeHintsRemaining - 1,
      totalHintsUsed: state.totalHintsUsed + 1,
      hintsUsedThisLevel: state.hintsUsedThisLevel + 1,
      lastHintTime: DateTime.now(),
    );
  }

  /// Consume a paid hint.
  void _consumePaidHint(String levelId) {
    state = state.copyWith(
      paidHintsUsed: state.paidHintsUsed + 1,
      totalHintsUsed: state.totalHintsUsed + 1,
      hintsUsedThisLevel: state.hintsUsedThisLevel + 1,
      lastHintTime: DateTime.now(),
    );

    // TODO: Deduct coins from player balance
  }

  /// Clear current hint (after user dismisses or makes move).
  void clearHint() {
    state = state.copyWith(currentHint: null);
  }

  /// Reset hints for new level.
  void resetForNewLevel() {
    state = state.copyWith(
      freeHintsRemaining: HintState.defaultFreeHints,
      hintsUsedThisLevel: 0,
      currentHint: null,
    );
  }

  /// Add bonus hints (from rewards, ads, etc.).
  void addBonusHints(int count) {
    state = state.copyWith(
      freeHintsRemaining: state.freeHintsRemaining + count,
    );
  }

  /// Get cooldown remaining in seconds.
  int getCooldownRemaining() {
    if (state.lastHintTime == null) return 0;

    final elapsed = DateTime.now().difference(state.lastHintTime!);
    final remaining = HintState.cooldownDuration - elapsed;

    if (remaining.isNegative) return 0;
    return remaining.inSeconds;
  }

  /// Update cooldown state (call periodically from UI).
  void updateCooldown() {
    final remaining = getCooldownRemaining();
    state = state.copyWith(
      cooldownRemainingSeconds: remaining,
    );
  }
}

/// Hint system state.
class HintState {
  /// Default free hints per level
  static const int defaultFreeHints = 3;

  /// Cooldown duration between free hints
  static const Duration cooldownDuration = Duration(seconds: 30);

  /// Cost of paid hint in coins
  static const int hintCostCoins = 10;

  /// Free hints remaining for current level
  final int freeHintsRemaining;

  /// Total paid hints used (all time)
  final int paidHintsUsed;

  /// Total hints used (all time)
  final int totalHintsUsed;

  /// Hints used in current level
  final int hintsUsedThisLevel;

  /// Currently active hint (null if none)
  final HintMove? currentHint;

  /// Last hint request time (for cooldown)
  final DateTime? lastHintTime;

  /// Cooldown remaining seconds (updated periodically)
  final int cooldownRemainingSeconds;

  const HintState({
    this.freeHintsRemaining = defaultFreeHints,
    this.paidHintsUsed = 0,
    this.totalHintsUsed = 0,
    this.hintsUsedThisLevel = 0,
    this.currentHint,
    this.lastHintTime,
    this.cooldownRemainingSeconds = 0,
  });

  /// Is hint available (free or paid)?
  bool get hasHintAvailable =>
      freeHintsRemaining > 0 || true; // Can always use coins

  /// Is currently on cooldown?
  bool get isOnCooldown => cooldownRemainingSeconds > 0;

  /// Can request free hint?
  bool get canRequestFreeHint =>
      freeHintsRemaining > 0 && !isOnCooldown;

  /// Has active hint being displayed?
  bool get hasActiveHint => currentHint != null;

  /// Create a copy with changes.
  HintState copyWith({
    int? freeHintsRemaining,
    int? paidHintsUsed,
    int? totalHintsUsed,
    int? hintsUsedThisLevel,
    HintMove? currentHint,
    DateTime? lastHintTime,
    int? cooldownRemainingSeconds,
  }) {
    return HintState(
      freeHintsRemaining: freeHintsRemaining ?? this.freeHintsRemaining,
      paidHintsUsed: paidHintsUsed ?? this.paidHintsUsed,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      hintsUsedThisLevel: hintsUsedThisLevel ?? this.hintsUsedThisLevel,
      currentHint: currentHint,
      lastHintTime: lastHintTime ?? this.lastHintTime,
      cooldownRemainingSeconds:
          cooldownRemainingSeconds ?? this.cooldownRemainingSeconds,
    );
  }

  @override
  String toString() {
    return 'HintState('
        'free: $freeHintsRemaining, '
        'paid: $paidHintsUsed, '
        'total: $totalHintsUsed, '
        'cooldown: ${cooldownRemainingSeconds}s'
        ')';
  }
}

/// Result of hint request.
class HintRequestResult {
  /// Whether hint request was successful
  final bool success;

  /// The hint move (null if failed)
  final HintMove? hint;

  /// Error message if failed
  final String? errorMessage;

  /// Whether player can use coins as alternative
  final bool canUseCoins;

  /// Search time in milliseconds
  final int? searchTimeMs;

  /// Number of moves to solution
  final int? movesToSolution;

  const HintRequestResult({
    required this.success,
    this.hint,
    this.errorMessage,
    this.canUseCoins = false,
    this.searchTimeMs,
    this.movesToSolution,
  });
}

// ═══════════════════════════════════════════════════════════════════
// RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════════

/// Provider for hint controller and state.
///
/// USAGE:
/// ```dart
/// // Watch hint state
/// final hintState = ref.watch(hintProvider);
///
/// // Request hint
/// final controller = ref.read(hintProvider.notifier);
/// final result = await controller.requestHint(
///   containers: gameState.containers,
///   levelId: levelId,
/// );
/// ```
final hintProvider = StateNotifierProvider<HintController, HintState>((ref) {
  return HintController();
});

/// Provider for free hints remaining.
final freeHintsRemainingProvider = Provider<int>((ref) {
  final state = ref.watch(hintProvider);
  return state.freeHintsRemaining;
});

/// Provider for whether hint is available.
final hintAvailableProvider = Provider<bool>((ref) {
  final state = ref.watch(hintProvider);
  return state.hasHintAvailable;
});

/// Provider for current active hint.
final currentHintProvider = Provider<HintMove?>((ref) {
  final state = ref.watch(hintProvider);
  return state.currentHint;
});

/// Provider for cooldown status.
final hintCooldownProvider = Provider<int>((ref) {
  final state = ref.watch(hintProvider);
  return state.cooldownRemainingSeconds;
});

/// Provider for whether can request free hint.
final canRequestFreeHintProvider = Provider<bool>((ref) {
  final state = ref.watch(hintProvider);
  return state.canRequestFreeHint;
});

// ═══════════════════════════════════════════════════════════════════
// HINT SYSTEM INTEGRATION NOTES
// ═══════════════════════════════════════════════════════════════════
//
// INTEGRATION POINTS:
//
// 1. GAME CONTROLLER:
//    - Call resetForNewLevel() when loading new level
//    - Call clearHint() when player makes move
//
// 2. COIN SYSTEM:
//    - Check coin balance before paid hint
//    - Deduct coins after successful paid hint
//    - Show purchase dialog if insufficient coins
//
// 3. ANALYTICS:
//    - Track hint usage per level
//    - Track free vs paid hint ratio
//    - Track hint effectiveness (did player solve after hint?)
//
// 4. UI:
//    - Show hint button with state (available/cooldown/cost)
//    - Show cooldown timer
//    - Show remaining free hints
//    - Show hint overlay when active
//
// 5. REWARDS:
//    - Bonus hints from daily rewards
//    - Bonus hints from watching ads
//    - Bonus hints from achievements
//
// MONETIZATION STRATEGY:
//
// Free hints are generous to:
// - Help players learn mechanics
// - Reduce frustration on hard levels
// - Build trust before asking for money
//
// Paid hints are available to:
// - Let stuck players progress
// - Monetize without forcing ads
// - Provide value for money spent
//
// Cooldown exists to:
// - Prevent hint spam
// - Encourage thinking before using hint
// - Make paid hints more valuable
// - Maintain game challenge
//
// ═══════════════════════════════════════════════════════════════════
