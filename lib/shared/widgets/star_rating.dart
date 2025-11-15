import 'package:flutter/material.dart';

/// Star rating display widget.
///
/// ═══════════════════════════════════════════════════════════════════
/// STAR RATING: Visual Performance Feedback
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Displays earned stars vs total stars with animation support.
/// Universal game mechanic for showing performance/achievement.
///
/// DESIGN PRINCIPLES:
/// 1. CLARITY:
///    - Filled stars = earned
///    - Empty stars = not earned
///    - Clear visual distinction
///
/// 2. ANIMATION:
///    - Stars fade in sequentially (stagger)
///    - Scale effect on appear
///    - Satisfying reveal
///
/// 3. REUSABILITY:
///    - Works in dialogs, lists, cards
///    - Configurable size
///    - Optional animation
///    - Customizable colors
///
/// 4. ACCESSIBILITY:
///    - Semantic label (e.g., "3 out of 5 stars")
///    - Works without color (shape distinction)
///
/// GAME PSYCHOLOGY:
/// - Star ratings are universally understood
/// - Missing stars create motivation to improve
/// - Full stars create satisfaction
/// - Partial completion drives engagement
///
/// SIMILAR PATTERNS:
/// - App store ratings (5 stars)
/// - Game level completion (Angry Birds: 3 stars)
/// - Skill ratings (chess: 5 stars)
/// - Hotel ratings (1-5 stars)
///
/// ═══════════════════════════════════════════════════════════════════
class StarRating extends StatelessWidget {
  /// Number of stars earned
  final int stars;

  /// Total number of stars possible
  final int totalStars;

  /// Size of each star
  final double size;

  /// Spacing between stars
  final double spacing;

  /// Color for filled stars
  final Color filledColor;

  /// Color for empty stars
  final Color emptyColor;

  /// Optional animation controller for entrance animation
  final AnimationController? animationController;

  const StarRating({
    super.key,
    required this.stars,
    this.totalStars = 3,
    this.size = 32,
    this.spacing = 4,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
    this.animationController,
  }) : assert(stars >= 0 && stars <= totalStars);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$stars out of $totalStars stars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          totalStars,
          (index) {
            final isFilled = index < stars;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _AnimatedStar(
                size: size,
                filled: isFilled,
                filledColor: filledColor,
                emptyColor: emptyColor,
                animationController: animationController,
                // Stagger animation: each star starts slightly later
                delay: Duration(milliseconds: index * 100),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Create a small compact star rating (for list items)
  factory StarRating.small({
    required int stars,
    int totalStars = 3,
    AnimationController? animationController,
  }) {
    return StarRating(
      stars: stars,
      totalStars: totalStars,
      size: 16,
      spacing: 2,
      animationController: animationController,
    );
  }

  /// Create a medium star rating (for cards)
  factory StarRating.medium({
    required int stars,
    int totalStars = 3,
    AnimationController? animationController,
  }) {
    return StarRating(
      stars: stars,
      totalStars: totalStars,
      size: 24,
      spacing: 4,
      animationController: animationController,
    );
  }

  /// Create a large star rating (for dialogs/headers)
  factory StarRating.large({
    required int stars,
    int totalStars = 3,
    AnimationController? animationController,
  }) {
    return StarRating(
      stars: stars,
      totalStars: totalStars,
      size: 48,
      spacing: 8,
      animationController: animationController,
    );
  }
}

/// Individual animated star
///
/// ANIMATION BREAKDOWN:
/// 1. Fade in: opacity 0 → 1
/// 2. Scale up: scale 0.5 → 1.0 → 1.0
/// 3. Slight overshoot for bounce feel
/// 4. Delayed start (stagger)
class _AnimatedStar extends StatefulWidget {
  final double size;
  final bool filled;
  final Color filledColor;
  final Color emptyColor;
  final AnimationController? animationController;
  final Duration delay;

  const _AnimatedStar({
    required this.size,
    required this.filled,
    required this.filledColor,
    required this.emptyColor,
    this.animationController,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _useLocalController = false;

  @override
  void initState() {
    super.initState();

    // Use provided controller or create local one
    if (widget.animationController != null) {
      _useLocalController = false;
      _setupAnimations(widget.animationController!);
    } else {
      _useLocalController = true;
      _localController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _setupAnimations(_localController);

      // Auto-start animation with delay
      Future.delayed(widget.delay, () {
        if (mounted) {
          _localController.forward();
        }
      });
    }
  }

  void _setupAnimations(AnimationController controller) {
    // Scale animation: start small, overshoot slightly, settle
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.1).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 40,
      ),
    ]).animate(controller);

    // Fade animation: simple fade in
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    if (_useLocalController) {
      _localController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        _useLocalController ? _localController : widget.animationController!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Clamp opacity to valid range [0.0, 1.0] to prevent assertion errors
        // This handles edge cases where animation controller might produce values outside this range
        final clampedOpacity = _fadeAnimation.value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: clampedOpacity,
            child: Icon(
              widget.filled ? Icons.star : Icons.star_border,
              size: widget.size,
              color: widget.filled ? widget.filledColor : widget.emptyColor,
            ),
          ),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// STATIC (No animation):
/// ```dart
/// StarRating(
///   stars: 2,
///   totalStars: 3,
/// )
/// ```
///
/// ANIMATED (With controller):
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget>
///     with SingleTickerProviderStateMixin {
///   late AnimationController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = AnimationController(
///       duration: Duration(milliseconds: 800),
///       vsync: this,
///     );
///     _controller.forward();
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return StarRating(
///       stars: 3,
///       totalStars: 3,
///       animationController: _controller,
///     );
///   }
/// }
/// ```
///
/// IN LIST:
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return ListTile(
///       title: Text('Level ${index + 1}'),
///       trailing: StarRating.small(
///         stars: level.starsEarned,
///       ),
///     );
///   },
/// )
/// ```
///
/// IN DIALOG:
/// ```dart
/// AlertDialog(
///   content: Column(
///     children: [
///       Text('Level Complete!'),
///       StarRating.large(
///         stars: 3,
///         animationController: _controller,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// CUSTOMIZATION OPTIONS
/// ═══════════════════════════════════════════════════════════════════
///
/// COLORS:
/// ```dart
/// StarRating(
///   stars: 3,
///   filledColor: Colors.orange,  // Custom filled color
///   emptyColor: Colors.grey[300], // Custom empty color
/// )
/// ```
///
/// SIZES:
/// ```dart
/// // Tiny (for dense layouts)
/// StarRating(stars: 2, size: 12)
///
/// // Small (for lists)
/// StarRating.small(stars: 2)
///
/// // Medium (for cards)
/// StarRating.medium(stars: 2)
///
/// // Large (for dialogs)
/// StarRating.large(stars: 2)
///
/// // Custom
/// StarRating(stars: 2, size: 64)
/// ```
///
/// SPACING:
/// ```dart
/// StarRating(
///   stars: 3,
///   spacing: 8,  // More space between stars
/// )
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// POLISH CHECKLIST
/// ═══════════════════════════════════════════════════════════════════
///
/// COMPLETED:
/// ✓ Clear visual distinction (filled/empty)
/// ✓ Smooth entrance animation
/// ✓ Staggered reveal (one at a time)
/// ✓ Accessibility (semantic labels)
/// ✓ Reusable across app
/// ✓ Multiple size presets
/// ✓ Customizable colors
/// ✓ Optional animation
///
/// TODO (Future enhancements):
/// □ Half-star support (e.g., 2.5/5)
/// □ Interactive rating (tap to rate)
/// □ Custom icons (hearts, gems, etc.)
/// □ Gradient fills
/// □ Glow effects
/// □ Count-up animation (0 → 3 stars)
/// □ Sound per star
///
/// ACCESSIBILITY NOTES:
/// - Works without color (shape difference)
/// - Semantic label for screen readers
/// - Sufficient contrast
/// - Touch-friendly sizing (when interactive)
///
/// GAME FEEL NOTES:
/// - Animation creates satisfaction
/// - Stagger adds drama/anticipation
/// - Overshoot (bounce) feels playful
/// - Instant feedback (no delay needed)
///
/// ═══════════════════════════════════════════════════════════════════
