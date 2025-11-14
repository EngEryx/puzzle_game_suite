import 'package:flutter/material.dart';
import '../../../core/models/achievement.dart';

/// Achievement unlock popup notification
///
/// DESIGN PRINCIPLES:
/// 1. Celebratory and rewarding feel
/// 2. Non-intrusive (toast-style)
/// 3. Auto-dismiss after delay
/// 4. Optional share functionality
/// 5. Satisfying animation
///
/// PSYCHOLOGY:
/// - Immediate feedback for unlocking
/// - Visual celebration creates positive reinforcement
/// - Share option increases engagement
///
/// Similar to:
/// - Steam achievement popup
/// - Xbox achievement toast
/// - Mobile game reward notifications
class AchievementPopup extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;
  final VoidCallback? onShare;
  final Duration displayDuration;

  const AchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.onShare,
    this.displayDuration = const Duration(seconds: 4),
  });

  /// Show achievement popup as an overlay
  static void show(
    BuildContext context,
    Achievement achievement, {
    VoidCallback? onShare,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => AchievementPopup(
        achievement: achievement,
        onDismiss: () => entry.remove(),
        onShare: onShare,
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation (bounce effect)
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Slide animation (from top)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start animation
    _controller.forward();

    // Auto-dismiss
    Future.delayed(widget.displayDuration, _dismiss);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    if (mounted) {
      await _controller.reverse();
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildPopupCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color(widget.achievement.rarityColor).withOpacity(0.9),
              Color(widget.achievement.rarityColor),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Confetti background effect
            Positioned.fill(
              child: _buildConfettiEffect(),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon with glow effect
                  _buildIconWithGlow(),
                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Achievement Unlocked!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.achievement.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade300,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.achievement.points} points',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade100,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Share button (if callback provided)
                      if (widget.onShare != null)
                        IconButton(
                          onPressed: () {
                            widget.onShare?.call();
                            _dismiss();
                          },
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),

                      const SizedBox(height: 8),

                      // Close button
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build icon with glow effect
  Widget _buildIconWithGlow() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.achievement.icon,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  /// Build confetti effect
  Widget _buildConfettiEffect() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _ConfettiPainter(
          animation: _controller,
        ),
      ),
    );
  }
}

/// Custom painter for confetti effect
class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;

  _ConfettiPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw simple confetti particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7 * animation.value) % size.height;

      paint.color = _getConfettiColor(i).withOpacity(0.3);

      canvas.drawCircle(
        Offset(x, y),
        3,
        paint,
      );
    }
  }

  Color _getConfettiColor(int index) {
    final colors = [
      Colors.yellow,
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Simpler achievement toast (alternative to popup)
///
/// Less intrusive than popup, good for multiple quick achievements
class AchievementToast {
  static void show(
    BuildContext context,
    Achievement achievement, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.star,
              color: Colors.amber.shade300,
              size: 20,
            ),
          ],
        ),
        backgroundColor: Color(achievement.rarityColor),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
