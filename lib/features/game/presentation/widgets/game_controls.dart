import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/game_controller.dart';
import '../../controller/hint_controller.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../shared/constants/animation_constants.dart';

/// Types of haptic feedback
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// Game control bar with Undo, Reset, and Hint buttons.
///
/// ═══════════════════════════════════════════════════════════════════
/// GAME CONTROLS: User Actions & Feedback
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Provides intuitive controls for game manipulation with proper
/// state-aware enabling/disabling and visual/haptic feedback.
///
/// DESIGN PRINCIPLES:
/// 1. STATE-AWARE: Buttons enable/disable based on game state
///    - Undo only if canUndo
///    - Reset always available
///    - Hint disabled for now (placeholder)
///
/// 2. VISUAL FEEDBACK:
///    - Press animations (scale down on tap)
///    - Color changes on disabled state
///    - Icons clearly indicate function
///
/// 3. HAPTIC FEEDBACK:
///    - Light impact on successful action
///    - Error vibration on invalid action
///    - Provides tactile confirmation
///
/// 4. ACCESSIBILITY:
///    - Semantic labels for screen readers
///    - Sufficient touch targets (48x48 minimum)
///    - High contrast colors
///    - Tooltips for clarity
///
/// SIMILAR PATTERNS:
/// - Mobile game control bars (Candy Crush, 2048)
/// - Video player controls (play/pause/skip)
/// - Document editing toolbars (undo/redo/save)
///
/// ═══════════════════════════════════════════════════════════════════
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch game state for button enabling
    final canUndo = ref.watch(canUndoProvider);
    final controller = ref.read(gameProvider.notifier);
    final audioService = ref.read(audioServiceProvider);

    // Watch hint state
    final hintState = ref.watch(hintProvider);
    final hintController = ref.read(hintProvider.notifier);
    final gameState = ref.watch(gameProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Undo Button
            _GameControlButton(
              icon: Icons.undo,
              label: 'Undo',
              enabled: canUndo,
              iconRotation: canUndo,
              onPressed: () {
                try {
                  controller.undo();
                  audioService.playMove();
                  _triggerHapticFeedback(context);

                  // Optional: Show subtle feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Move undone'),
                      duration: Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  audioService.playError();
                  _showError(context, 'Cannot undo: ${e.toString()}');
                }
              },
              tooltip: canUndo
                  ? 'Undo last move'
                  : 'No moves to undo',
            ),

            // Reset Button
            _GameControlButton(
              icon: Icons.refresh,
              label: 'Reset',
              enabled: true,
              iconRotation: true,
              onPressed: () {
                // Show confirmation dialog for destructive action
                _showResetConfirmation(
                  context,
                  controller,
                  audioService,
                );
              },
              tooltip: 'Reset puzzle to start',
            ),

            // Hint Button
            _GameControlButton(
              icon: hintState.freeHintsRemaining > 0
                  ? Icons.lightbulb_outline
                  : Icons.lightbulb,
              label: hintState.isOnCooldown
                  ? '${hintState.cooldownRemainingSeconds}s'
                  : hintState.freeHintsRemaining > 0
                      ? 'Hint (${hintState.freeHintsRemaining})'
                      : 'Hint',
              enabled: !isGameOver &&
                       (hintState.canRequestFreeHint || hintState.freeHintsRemaining == 0),
              shouldPulse: hintState.canRequestFreeHint && !isGameOver,
              onPressed: () => _handleHintRequest(
                context,
                ref,
                hintController,
                gameState,
                audioService,
              ),
              tooltip: hintState.isOnCooldown
                  ? 'Hint cooldown: ${hintState.cooldownRemainingSeconds}s'
                  : hintState.freeHintsRemaining > 0
                      ? '${hintState.freeHintsRemaining} free hints remaining'
                      : 'Get hint (${HintState.hintCostCoins} coins)',
            ),
          ],
        ),
      ),
    );
  }

  /// Trigger haptic feedback
  ///
  /// PLATFORM DIFFERENCES:
  /// - iOS: Uses UIImpactFeedbackGenerator
  /// - Android: Uses Vibrator with pattern
  /// - Web/Desktop: No effect (gracefully degrades)
  void _triggerHapticFeedback(BuildContext context, {HapticFeedbackType type = HapticFeedbackType.light}) {
    try {
      switch (type) {
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
        case HapticFeedbackType.heavy:
          HapticFeedback.heavyImpact();
        case HapticFeedbackType.selection:
          HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Haptic feedback not available on this platform
      // Fail gracefully
    }
  }

  /// Show reset confirmation dialog
  ///
  /// BEST PRACTICE: Confirm destructive actions
  /// Prevents accidental resets that lose progress
  void _showResetConfirmation(
    BuildContext context,
    GameController controller,
    AudioService audioService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Puzzle?'),
        content: const Text(
          'This will reset the puzzle to its starting state. '
          'All your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.reset();
              audioService.playMove();
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Puzzle reset'),
                  duration: Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle hint request
  Future<void> _handleHintRequest(
    BuildContext context,
    WidgetRef ref,
    HintController hintController,
    dynamic gameState,
    AudioService audioService,
  ) async {
    // Check if on cooldown
    if (ref.read(hintProvider).isOnCooldown) {
      final remaining = ref.read(hintProvider).cooldownRemainingSeconds;
      _showError(context, 'Hint on cooldown. Wait ${remaining}s');
      audioService.playError();
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Analyzing puzzle...'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Request hint
    final result = await hintController.requestHint(
      containers: gameState.containers,
      levelId: gameState.level.id,
      useCoins: ref.read(hintProvider).freeHintsRemaining <= 0,
    );

    // Dismiss loading
    ScaffoldMessenger.of(context).clearSnackBars();

    if (!result.success) {
      // Show error or coin purchase option
      if (result.canUseCoins) {
        _showCoinHintDialog(context, ref, hintController, gameState, audioService);
      } else {
        _showError(context, result.errorMessage ?? 'No hint available');
        audioService.playError();
      }
      return;
    }

    // Success - hint is now active and will be displayed by hint overlay
    audioService.playMove();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.movesToSolution != null
              ? 'Hint: ${result.movesToSolution} moves to solution'
              : 'Hint available',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    // Start cooldown timer update
    _startCooldownTimer(ref);
  }

  /// Show dialog for paid hint
  void _showCoinHintDialog(
    BuildContext context,
    WidgetRef ref,
    HintController hintController,
    dynamic gameState,
    AudioService audioService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Coins for Hint?'),
        content: Text(
          'No free hints remaining.\n\n'
          'Use ${HintState.hintCostCoins} coins for a hint?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Request paid hint
              final result = await hintController.requestHint(
                containers: gameState.containers,
                levelId: gameState.level.id,
                useCoins: true,
              );

              if (result.success) {
                audioService.playMove();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hint purchased'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                audioService.playError();
                _showError(context, result.errorMessage ?? 'Failed to purchase hint');
              }
            },
            child: Text('Use ${HintState.hintCostCoins} Coins'),
          ),
        ],
      ),
    );
  }

  /// Start cooldown timer updates
  void _startCooldownTimer(WidgetRef ref) {
    // Update cooldown every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (ref.read(hintProvider).isOnCooldown) {
        ref.read(hintProvider.notifier).updateCooldown();
        return true; // Continue
      }
      return false; // Stop
    });
  }
}

/// Individual control button with consistent styling and feedback.
///
/// COMPONENT DESIGN:
/// - Self-contained (owns its animation state)
/// - Consistent sizing (48x48 minimum touch target)
/// - Clear visual feedback (scale, opacity)
/// - Accessible (tooltips, semantic labels)
///
/// ANIMATION:
/// - Press: Scale down to 0.95 (subtle feedback)
/// - Release: Spring back to 1.0
/// - Disabled: Reduced opacity (0.4)
class _GameControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final String tooltip;
  final bool iconRotation;
  final bool shouldPulse;

  const _GameControlButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.tooltip,
    this.iconRotation = false,
    this.shouldPulse = false,
  });

  @override
  State<_GameControlButton> createState() => _GameControlButtonState();
}

class _GameControlButtonState extends State<_GameControlButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  bool _wasEnabled = false;

  @override
  void initState() {
    super.initState();
    _wasEnabled = widget.enabled;

    // Press animation controller
    _pressController = AnimationController(
      duration: AnimationConstants.ultraFast,
      vsync: this,
    );

    // Scale from 1.0 to buttonPressScale on press
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationConstants.buttonPressScale,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: AnimationConstants.spring,
      ),
    );

    // Rotation animation (for undo and reset icons)
    _rotationController = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: AnimationConstants.spring,
      ),
    );

    // Pulse animation (for hint button)
    _pulseController = AnimationController(
      duration: AnimationConstants.pulseInterval,
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0),
        weight: 50,
      ),
    ]).animate(_pulseController);

    if (widget.shouldPulse && widget.enabled) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(_GameControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger rotation when enabled state changes
    if (widget.enabled != _wasEnabled && widget.iconRotation) {
      _wasEnabled = widget.enabled;
      if (widget.enabled) {
        _rotationController.forward(from: 0.0);
      }
    }

    // Control pulse animation
    if (widget.shouldPulse != oldWidget.shouldPulse ||
        widget.enabled != oldWidget.enabled) {
      if (widget.shouldPulse && widget.enabled) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _pressController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: AnimatedOpacity(
                duration: AnimationConstants.fast,
                opacity: widget.enabled
                    ? 1.0
                    : AnimationConstants.disabledOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon button with ripple effect
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.enabled
                            ? colorScheme.primaryContainer
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: widget.enabled
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: widget.iconRotation
                                ? _rotationAnimation.value *
                                    -AnimationConstants.fullTurn
                                : 0.0,
                            child: Icon(
                              widget.icon,
                              size: 28,
                              color: widget.enabled
                                  ? colorScheme.onPrimaryContainer
                                  : Colors.grey.shade500,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Label
                    Text(
                      widget.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: widget.enabled
                            ? colorScheme.onSurface
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// POLISH CHECKLIST
/// ═══════════════════════════════════════════════════════════════════
///
/// COMPLETED:
/// ✓ State-aware button enabling
/// ✓ Visual press feedback
/// ✓ Tooltips for accessibility
/// ✓ Confirmation dialog for reset
/// ✓ Error handling with user feedback
/// ✓ Consistent sizing (accessibility)
/// ✓ High contrast colors
///
/// TODO (Week 2):
/// ✓ Enhanced button press animations
/// ✓ Icon rotation animations (undo, reset)
/// ✓ Pulse animation for hints
/// ✓ Smooth state transitions
/// ✓ Using animation constants
/// □ Implement actual haptic feedback
/// □ Add hint system implementation
/// □ Add keyboard shortcuts (web/desktop)
/// □ Implement undo limit (optional)
/// □ Add double-tap to reset shortcut
/// □ Track analytics events
///
/// ACCESSIBILITY NOTES:
/// - All buttons have semantic labels
/// - Touch targets meet 48x48 minimum
/// - Visual feedback doesn't rely on color alone
/// - Tooltips provide additional context
/// - Screen reader support through Semantics
///
/// GAME FEEL NOTES:
/// - Immediate visual feedback on interaction
/// - Sound effects reinforce actions
/// - Haptic feedback adds tactile dimension
/// - Confirmations prevent frustration
/// - Snackbars provide non-intrusive feedback
///
/// ═══════════════════════════════════════════════════════════════════
