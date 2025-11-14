import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controller/game_controller.dart';
import '../../../../shared/widgets/star_rating.dart';
import '../../../../core/services/audio_service.dart';

/// Dialog shown when player completes a level.
///
/// ═══════════════════════════════════════════════════════════════════
/// WIN DIALOG: Celebration & Navigation
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Celebrates player success with:
/// - Visual celebration (stars, colors, animations)
/// - Performance feedback (move count, stars earned)
/// - Clear next actions (next level, replay, home)
///
/// DESIGN PRINCIPLES:
/// 1. CELEBRATE SUCCESS:
///    - Bright, positive colors
///    - Star rating prominently displayed
///    - Encouraging messages
///    - Satisfying animations
///
/// 2. CLEAR ACTIONS:
///    - Primary: Next Level (continue playing)
///    - Secondary: Replay (improve score)
///    - Tertiary: Home (take a break)
///
/// 3. CONTEXT:
///    - Show performance metrics
///    - Compare to star thresholds
///    - Give sense of achievement
///
/// 4. NON-BLOCKING:
///    - Can dismiss without action
///    - Actions are suggestions, not requirements
///
/// PSYCHOLOGY:
/// - Variable rewards (stars) drive engagement
/// - Immediate feedback reinforces success
/// - Clear progress path encourages continuation
/// - Option to improve creates replay value
///
/// SIMILAR PATTERNS:
/// - Mobile game victory screens (Angry Birds, Crossy Road)
/// - Achievement unlocked notifications
/// - E-learning completion dialogs
///
/// ═══════════════════════════════════════════════════════════════════
class WinDialog extends ConsumerStatefulWidget {
  const WinDialog({super.key});

  /// Show the win dialog
  ///
  /// USAGE:
  /// ```dart
  /// if (gameState.isWon) {
  ///   WinDialog.show(context);
  /// }
  /// ```
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Require explicit action
      builder: (context) => const WinDialog(),
    );
  }

  @override
  ConsumerState<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends ConsumerState<WinDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _starController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Play win sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playWin();
    });

    // Slide-in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      ),
    );

    // Star animation (staggered)
    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    _slideController.forward();
    _starController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameState = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final stars = gameState.currentStars;
    final moveCount = gameState.moveCount;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade50,
                  Colors.orange.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.amber.shade700,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Level Complete!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),

                const SizedBox(height: 8),

                // Encouraging message based on performance
                Text(
                  _getEncouragingMessage(stars),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Star rating
                AnimatedBuilder(
                  animation: _starController,
                  builder: (context, child) {
                    return StarRating(
                      stars: stars,
                      totalStars: 3,
                      size: 48,
                      animationController: _starController,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Stats card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.swap_horiz,
                        label: 'Moves Used',
                        value: moveCount.toString(),
                      ),
                      if (gameState.level.starThresholds != null) ...[
                        const SizedBox(height: 8),
                        _StatRow(
                          icon: Icons.star,
                          label: 'Best Possible',
                          value:
                              '${gameState.level.starThresholds![2]} moves',
                          isSubtle: true,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Column(
                  children: [
                    // Primary: Next Level
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Load next level
                          // For now, just show placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Next level coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next Level'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.amber.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Secondary actions row
                    Row(
                      children: [
                        // Replay
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              controller.reset();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Level reset - try for more stars!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.replay),
                            label: const Text('Replay'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Home
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/');
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Home'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get encouraging message based on star rating
  ///
  /// PSYCHOLOGY: Positive reinforcement for all outcomes
  /// Even 1 star gets celebration, but better performance
  /// gets more enthusiastic messages
  String _getEncouragingMessage(int stars) {
    switch (stars) {
      case 3:
        return 'Perfect! You solved it optimally!';
      case 2:
        return 'Great job! Can you do it in fewer moves?';
      case 1:
        return 'Good work! Try again for more stars!';
      default:
        return 'You did it! Every puzzle solved is progress!';
    }
  }
}

/// Statistic row for displaying info
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSubtle;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isSubtle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSubtle ? Colors.grey.shade600 : Colors.grey.shade800;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// POLISH CHECKLIST
/// ═══════════════════════════════════════════════════════════════════
///
/// COMPLETED:
/// ✓ Celebratory design (colors, trophy icon)
/// ✓ Star rating display
/// ✓ Performance metrics (move count)
/// ✓ Encouraging messages
/// ✓ Clear action hierarchy
/// ✓ Entry animations (slide + fade)
/// ✓ Non-dismissible (requires action)
/// ✓ Audio feedback (win sound)
///
/// TODO (Week 2):
/// □ Confetti/particle effects
/// □ Star count-up animation
/// □ Share score functionality
/// □ Leaderboard integration
/// □ Achievement unlocks
/// □ Statistics tracking
/// □ Personal best indicators
/// □ Next level preview
/// □ Ad integration (optional)
///
/// ACCESSIBILITY NOTES:
/// - High contrast text
/// - Clear button labels
/// - Semantic structure
/// - Screen reader friendly
/// - Keyboard navigation support
///
/// GAME FEEL NOTES:
/// - Immediate celebration (sound + animation)
/// - Variable reward (stars) creates excitement
/// - Performance context (not just win/lose)
/// - Positive reinforcement always
/// - Clear next steps reduce friction
/// - Replay option encourages mastery
///
/// UX PATTERNS:
/// - Primary action is most prominent
/// - Destructive actions (none) would be subtle
/// - Confirmation only for next level (commitment)
/// - Home is always accessible (escape hatch)
///
/// ═══════════════════════════════════════════════════════════════════
