import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../constants/animation_constants.dart';

/// Bounce animation helper using spring physics for natural, playful effects.
///
/// ═══════════════════════════════════════════════════════════════════
/// BOUNCE EFFECT: Spring Physics Animations
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Creates natural, physics-based bounce animations for:
/// - Button presses
/// - Interactive elements
/// - Success celebrations
/// - Entry/exit animations
///
/// DESIGN PRINCIPLES:
/// 1. NATURAL PHYSICS:
///    - Uses real spring simulation
///    - Feels organic, not mechanical
///    - Adjustable stiffness and damping
///
/// 2. REUSABILITY:
///    - Works with any widget
///    - Configurable parameters
///    - Multiple presets for common cases
///
/// 3. PERFORMANCE:
///    - GPU-accelerated transforms
///    - Efficient animation controller
///    - Auto-cleanup
///
/// PSYCHOLOGY:
/// - Bounce feels playful and friendly
/// - Spring physics feel natural (match real world)
/// - Overshoot creates satisfaction
/// - Movement draws attention
///
/// ═══════════════════════════════════════════════════════════════════

/// Widget that bounces its child using spring physics
class BounceEffect extends StatefulWidget {
  /// Child widget to animate
  final Widget child;

  /// Controller to trigger bounce
  final BounceController controller;

  /// Spring description for physics
  final SpringDescription spring;

  /// Whether to scale (true) or translate (false)
  final bool useScale;

  const BounceEffect({
    super.key,
    required this.child,
    required this.controller,
    this.spring = AnimationConstants.bouncySpring,
    this.useScale = true,
  });

  /// Gentle bounce for subtle feedback
  factory BounceEffect.gentle({
    required Widget child,
    required BounceController controller,
  }) {
    return BounceEffect(
      controller: controller,
      spring: AnimationConstants.gentleSpring,
      useScale: true,
      child: child,
    );
  }

  /// Bouncy for fun, playful effects
  factory BounceEffect.bouncy({
    required Widget child,
    required BounceController controller,
  }) {
    return BounceEffect(
      controller: controller,
      spring: AnimationConstants.bouncySpring,
      useScale: true,
      child: child,
    );
  }

  /// Snappy for quick responses
  factory BounceEffect.snappy({
    required Widget child,
    required BounceController controller,
  }) {
    return BounceEffect(
      controller: controller,
      spring: AnimationConstants.snappySpring,
      useScale: true,
      child: child,
    );
  }

  /// Wobbly for exaggerated celebration
  factory BounceEffect.wobbly({
    required Widget child,
    required BounceController controller,
  }) {
    return BounceEffect(
      controller: controller,
      spring: AnimationConstants.wobblySpring,
      useScale: true,
      child: child,
    );
  }

  @override
  State<BounceEffect> createState() => _BounceEffectState();
}

class _BounceEffectState extends State<BounceEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController.unbounded(vsync: this);
    _animation = _controller;

    // Listen to bounce controller
    widget.controller._addListener(_bounce);
  }

  @override
  void dispose() {
    widget.controller._removeListener(_bounce);
    _controller.dispose();
    super.dispose();
  }

  void _bounce() {
    final simulation = SpringSimulation(
      widget.spring,
      0.0, // Start at rest
      widget.controller._targetValue,
      widget.controller._velocity,
    );

    _controller.animateWith(simulation).then((_) {
      // Reset to rest after animation
      if (mounted) {
        _controller.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = 1.0 + _animation.value;

        if (widget.useScale) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        } else {
          return Transform.translate(
            offset: Offset(0, _animation.value * 10),
            child: child,
          );
        }
      },
      child: widget.child,
    );
  }
}

/// Controller for triggering bounces
class BounceController {
  final List<VoidCallback> _listeners = [];
  double _targetValue = 0.1; // How far to bounce
  double _velocity = 0.0; // Initial velocity

  /// Trigger a bounce with default values
  void bounce() {
    _targetValue = 0.1;
    _velocity = 0.0;
    _notifyListeners();
  }

  /// Trigger a small bounce
  void bounceSmall() {
    _targetValue = 0.05;
    _velocity = 0.0;
    _notifyListeners();
  }

  /// Trigger a medium bounce
  void bounceMedium() {
    _targetValue = 0.1;
    _velocity = 0.0;
    _notifyListeners();
  }

  /// Trigger a large bounce
  void bounceLarge() {
    _targetValue = 0.15;
    _velocity = 0.0;
    _notifyListeners();
  }

  /// Trigger a bounce with custom values
  void bounceCustom({
    required double targetValue,
    double velocity = 0.0,
  }) {
    _targetValue = targetValue;
    _velocity = velocity;
    _notifyListeners();
  }

  void _addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void _removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Dispose the controller
  void dispose() {
    _listeners.clear();
  }
}

/// Implicit animation widget that bounces on value change
class AnimatedBounce extends StatefulWidget {
  /// Child widget to animate
  final Widget child;

  /// Trigger value - bounce when this changes
  final dynamic trigger;

  /// Spring description
  final SpringDescription spring;

  /// Duration for the bounce
  final Duration duration;

  const AnimatedBounce({
    super.key,
    required this.child,
    required this.trigger,
    this.spring = AnimationConstants.bouncySpring,
    this.duration = AnimationConstants.medium,
  });

  @override
  State<AnimatedBounce> createState() => _AnimatedBounceState();
}

class _AnimatedBounceState extends State<AnimatedBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  dynamic _previousTrigger;

  @override
  void initState() {
    super.initState();
    _previousTrigger = widget.trigger;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedBounce oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger bounce if trigger value changed
    if (widget.trigger != _previousTrigger) {
      _previousTrigger = widget.trigger;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Button wrapper that bounces on press
class BounceButton extends StatefulWidget {
  /// Child widget
  final Widget child;

  /// On tap callback
  final VoidCallback? onTap;

  /// Spring to use
  final SpringDescription spring;

  /// Whether button is enabled
  final bool enabled;

  const BounceButton({
    super.key,
    required this.child,
    this.onTap,
    this.spring = AnimationConstants.snappySpring,
    this.enabled = true,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.ultraFast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationConstants.buttonPressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.spring,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// EXPLICIT BOUNCE (with controller):
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   late BounceController _bounceController;
///
///   @override
///   void initState() {
///     super.initState();
///     _bounceController = BounceController();
///   }
///
///   @override
///   void dispose() {
///     _bounceController.dispose();
///     super.dispose();
///   }
///
///   void _onSuccess() {
///     _bounceController.bounceLarge();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return BounceEffect.bouncy(
///       controller: _bounceController,
///       child: Icon(Icons.star, size: 48),
///     );
///   }
/// }
/// ```
///
/// IMPLICIT BOUNCE (on value change):
/// ```dart
/// int _score = 0;
///
/// Widget build(BuildContext context) {
///   return AnimatedBounce(
///     trigger: _score, // Bounces whenever score changes
///     child: Text('Score: $_score'),
///   );
/// }
/// ```
///
/// BOUNCE BUTTON:
/// ```dart
/// BounceButton(
///   onTap: () => print('Tapped!'),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     decoration: BoxDecoration(
///       color: Colors.blue,
///       borderRadius: BorderRadius.circular(12),
///     ),
///     child: Text('Press Me'),
///   ),
/// )
/// ```
///
/// WIN DIALOG TROPHY:
/// ```dart
/// class WinDialog extends StatefulWidget {
///   @override
///   State<WinDialog> createState() => _WinDialogState();
/// }
///
/// class _WinDialogState extends State<WinDialog> {
///   late BounceController _trophyBounce;
///
///   @override
///   void initState() {
///     super.initState();
///     _trophyBounce = BounceController();
///
///     // Bounce trophy after dialog appears
///     Future.delayed(Duration(milliseconds: 300), () {
///       _trophyBounce.bounceLarge();
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Dialog(
///       child: Column(
///         children: [
///           BounceEffect.wobbly(
///             controller: _trophyBounce,
///             child: Icon(Icons.emoji_events, size: 64),
///           ),
///           Text('You Win!'),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// SCORE INCREMENT:
/// ```dart
/// AnimatedBounce(
///   trigger: score,
///   spring: AnimationConstants.snappySpring,
///   child: Text(
///     'Score: $score',
///     style: TextStyle(fontSize: 24),
///   ),
/// )
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// BEST PRACTICES
/// ═══════════════════════════════════════════════════════════════════
///
/// DO:
/// ✓ Use gentle spring for buttons
/// ✓ Use bouncy spring for success states
/// ✓ Use wobbly spring sparingly (big wins)
/// ✓ Combine with other feedback (sound, haptic)
/// ✓ Dispose controllers properly
///
/// DON'T:
/// ✗ Overuse (not every element needs bounce)
/// ✗ Use slow springs for buttons (feels laggy)
/// ✗ Use wobbly springs everywhere (too much)
/// ✗ Bounce continuously (annoying)
///
/// SPRING SELECTION GUIDE:
/// - Buttons: gentle or snappy
/// - Icons: bouncy
/// - Dialogs: bouncy
/// - Celebrations: wobbly
/// - Scores/Numbers: snappy
///
/// PERFORMANCE:
/// - Uses Transform (GPU-accelerated)
/// - Physics simulation is efficient
/// - No layout recalculation
/// - 60fps easily achieved
///
/// ACCESSIBILITY:
/// - Check reduced motion preferences
/// - Provide instant alternative if needed
/// - Don't rely on bounce to convey info
///
/// ═══════════════════════════════════════════════════════════════════
