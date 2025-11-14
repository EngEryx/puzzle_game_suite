import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/level.dart';
import '../../../../core/services/progress_service.dart';
import '../../controller/level_progress_controller.dart';

/// Individual level card widget
///
/// DESIGN PATTERN: Stateless + Riverpod Consumer
///
/// VISUAL STATES:
/// 1. Locked: Greyed out, shows lock icon
/// 2. Unlocked: Full color, ready to play
/// 3. In Progress: Partial stars, shows progress
/// 4. Completed: All stars filled, success indicator
///
/// INTERACTION:
/// - Tap to start level (if unlocked)
/// - Long press for level details (future)
/// - Visual feedback on tap
///
/// UI INSPIRATION:
/// - Candy Crush level selector
/// - Angry Birds level map
/// - Monument Valley level grid
class LevelCard extends ConsumerWidget {
  final Level level;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch progress for this specific level
    final progress = ref.watch(levelProgressByIdProvider(level.id));
    final isUnlocked = ref.watch(levelUnlockedProvider(level.id));

    // Determine card state
    final cardState = _getCardState(isUnlocked, progress);

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _getGradient(cardState, level.difficulty),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _getShadows(cardState),
          border: Border.all(
            color: _getBorderColor(cardState),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern (subtle)
            if (cardState != LevelCardState.locked)
              _buildBackgroundPattern(),

            // Main content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top row: Difficulty indicator
                  _buildDifficultyBadge(level.difficulty, cardState),

                  // Center: Level number
                  Expanded(
                    child: Center(
                      child: _buildLevelNumber(cardState),
                    ),
                  ),

                  // Bottom: Stars or lock icon
                  _buildBottomSection(cardState, progress),
                ],
              ),
            ),

            // Locked overlay
            if (cardState == LevelCardState.locked)
              _buildLockedOverlay(),
          ],
        ),
      ),
    );
  }

  /// Determine card state based on unlock status and progress
  LevelCardState _getCardState(bool isUnlocked, LevelProgress? progress) {
    if (!isUnlocked) return LevelCardState.locked;
    if (progress == null) return LevelCardState.unlocked;
    if (progress.completed && progress.stars == 3) {
      return LevelCardState.perfect;
    }
    if (progress.completed) return LevelCardState.completed;
    return LevelCardState.inProgress;
  }

  /// Build difficulty badge
  Widget _buildDifficultyBadge(Difficulty difficulty, LevelCardState state) {
    if (state == LevelCardState.locked) {
      return const SizedBox(height: 20);
    }

    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        difficulty.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Build level number display
  Widget _buildLevelNumber(LevelCardState state) {
    // Extract level number from ID (e.g., "level_5" -> 5)
    final match = RegExp(r'level_(\d+)').firstMatch(level.id);
    final levelNum = match != null ? match.group(1) ?? '?' : '?';

    return Text(
      levelNum,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: state == LevelCardState.locked
            ? Colors.grey.shade400
            : Colors.white,
        shadows: state != LevelCardState.locked
            ? [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ]
            : null,
      ),
    );
  }

  /// Build bottom section (stars or lock)
  Widget _buildBottomSection(LevelCardState state, LevelProgress? progress) {
    if (state == LevelCardState.locked) {
      return const Icon(
        Icons.lock,
        color: Colors.grey,
        size: 24,
      );
    }

    return _buildStars(progress?.stars ?? 0);
  }

  /// Build star display
  Widget _buildStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isFilled = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? Colors.amber : Colors.white.withOpacity(0.5),
            size: 16,
          ),
        );
      }),
    );
  }

  /// Build locked overlay
  Widget _buildLockedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.lock,
          color: Colors.white70,
          size: 48,
        ),
      ),
    );
  }

  /// Build subtle background pattern
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
      ),
    );
  }

  /// Get gradient based on state and difficulty
  LinearGradient _getGradient(LevelCardState state, Difficulty difficulty) {
    if (state == LevelCardState.locked) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade300,
          Colors.grey.shade400,
        ],
      );
    }

    final baseColor = _getDifficultyColor(difficulty);

    switch (state) {
      case LevelCardState.perfect:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade400,
            Colors.orange.shade600,
          ],
        );
      case LevelCardState.completed:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.8),
            baseColor,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(0.7),
            baseColor.withOpacity(0.9),
          ],
        );
    }
  }

  /// Get shadows based on state
  List<BoxShadow> _getShadows(LevelCardState state) {
    if (state == LevelCardState.locked) {
      return [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 4),
        blurRadius: 8,
      ),
      if (state == LevelCardState.perfect)
        BoxShadow(
          color: Colors.amber.withOpacity(0.5),
          offset: const Offset(0, 0),
          blurRadius: 12,
          spreadRadius: 1,
        ),
    ];
  }

  /// Get border color based on state
  Color _getBorderColor(LevelCardState state) {
    switch (state) {
      case LevelCardState.locked:
        return Colors.grey.shade300;
      case LevelCardState.perfect:
        return Colors.amber.shade600;
      case LevelCardState.completed:
        return Colors.white.withOpacity(0.3);
      default:
        return Colors.white.withOpacity(0.2);
    }
  }

  /// Get color based on difficulty
  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green.shade600;
      case Difficulty.medium:
        return Colors.blue.shade600;
      case Difficulty.hard:
        return Colors.orange.shade700;
      case Difficulty.expert:
        return Colors.red.shade700;
    }
  }
}

/// Card state enum
enum LevelCardState {
  locked,       // Not unlocked yet
  unlocked,     // Unlocked but not played
  inProgress,   // Started but not completed
  completed,    // Completed with 1-2 stars
  perfect,      // Completed with 3 stars
}

/// Custom painter for background pattern
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines pattern
    const spacing = 20.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated level card with entrance animation
///
/// USE CASE: When level selector screen first loads, cards animate in
class AnimatedLevelCard extends StatefulWidget {
  final Level level;
  final VoidCallback? onTap;
  final int index;

  const AnimatedLevelCard({
    super.key,
    required this.level,
    this.onTap,
    required this.index,
  });

  @override
  State<AnimatedLevelCard> createState() => _AnimatedLevelCardState();
}

class _AnimatedLevelCardState extends State<AnimatedLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Stagger animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: LevelCard(
          level: widget.level,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
