import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

/// Screen shake effect for errors and big wins.
///
/// ═══════════════════════════════════════════════════════════════════
/// SCREEN SHAKE: Tactile Feedback Through Motion
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Adds physical feedback to game events:
/// - Errors (light shake)
/// - Invalid moves (medium shake)
/// - Big wins/achievements (heavy shake)
/// - Critical events (custom intensity)
///
/// DESIGN PRINCIPLES:
/// 1. SUBTLE BUT NOTICEABLE:
///    - Small displacement (2-10 pixels)
///    - Quick duration (300-500ms)
///    - Smooth easing (not jarring)
///
/// 2. CONTEXT APPROPRIATE:
///    - Light shake for minor feedback
///    - Medium shake for errors
///    - Heavy shake for dramatic moments
///
/// 3. PERFORMANCE:
///    - Uses Transform (GPU-accelerated)
///    - No layout recalculation
///    - Smooth 60fps animation
///
/// PSYCHOLOGY:
/// - Mimics physical impact/vibration
/// - Grabs attention without disrupting flow
/// - Reinforces negative/positive feedback
/// - Feels more "real" than static UI
///
/// ═══════════════════════════════════════════════════════════════════
class ScreenShake extends StatefulWidget {
  /// Child widget to shake
  final Widget child;

  /// Shake controller to trigger shake
  final ScreenShakeController controller;

  const ScreenShake({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AnimationConstants.shakeDuration,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to controller
    widget.controller._addListener(_shake);
  }

  @override
  void dispose() {
    widget.controller._removeListener(_shake);
    _animationController.dispose();
    super.dispose();
  }

  void _shake() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _calculateOffset(
          _shakeAnimation.value,
          widget.controller._intensity,
        );
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  /// Calculate shake offset at given progress
  ///
  /// ALGORITHM:
  /// - Uses sine wave for smooth oscillation
  /// - Amplitude decreases over time (decay)
  /// - Random direction for natural feel
  Offset _calculateOffset(double progress, double intensity) {
    if (progress == 0.0) return Offset.zero;

    // Decay: shake amplitude decreases over time
    final decay = 1.0 - progress;

    // Oscillation: multiple shakes that slow down
    final frequency = 10.0; // Number of shakes
    final oscillation = math.sin(progress * frequency * math.pi);

    // Calculate displacement
    final displacement = intensity * decay * oscillation;

    // Random angle for more natural shake
    final angle = widget.controller._angle;
    final dx = math.cos(angle) * displacement;
    final dy = math.sin(angle) * displacement;

    return Offset(dx, dy);
  }
}

/// Controller for triggering screen shake
class ScreenShakeController {
  final List<VoidCallback> _listeners = [];
  double _intensity = AnimationConstants.mediumShakeIntensity;
  double _angle = 0.0;

  /// Trigger a shake with given intensity
  void shake({double? intensity}) {
    _intensity = intensity ?? AnimationConstants.mediumShakeIntensity;
    _angle = math.Random().nextDouble() * math.pi * 2;
    _notifyListeners();
  }

  /// Light shake for minor feedback
  void shakeLight() {
    shake(intensity: AnimationConstants.lightShakeIntensity);
  }

  /// Medium shake for errors
  void shakeMedium() {
    shake(intensity: AnimationConstants.mediumShakeIntensity);
  }

  /// Heavy shake for big events
  void shakeHeavy() {
    shake(intensity: AnimationConstants.heavyShakeIntensity);
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

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// BASIC USAGE:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   late ScreenShakeController _shakeController;
///
///   @override
///   void initState() {
///     super.initState();
///     _shakeController = ScreenShakeController();
///   }
///
///   @override
///   void dispose() {
///     _shakeController.dispose();
///     super.dispose();
///   }
///
///   void _onError() {
///     _shakeController.shakeMedium();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ScreenShake(
///       controller: _shakeController,
///       child: Scaffold(
///         body: YourContent(),
///       ),
///     );
///   }
/// }
/// ```
///
/// GAME SCREEN:
/// ```dart
/// class GameScreen extends StatefulWidget {
///   @override
///   State<GameScreen> createState() => _GameScreenState();
/// }
///
/// class _GameScreenState extends State<GameScreen> {
///   late ScreenShakeController _shakeController;
///
///   @override
///   void initState() {
///     super.initState();
///     _shakeController = ScreenShakeController();
///   }
///
///   void _onInvalidMove() {
///     _shakeController.shakeLight();
///     // Show error message
///   }
///
///   void _onLevelComplete() {
///     _shakeController.shakeHeavy();
///     // Show win dialog
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ScreenShake(
///       controller: _shakeController,
///       child: Scaffold(
///         body: GameBoard(
///           onInvalidMove: _onInvalidMove,
///           onLevelComplete: _onLevelComplete,
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// WITH RIVERPOD:
/// ```dart
/// final shakeControllerProvider = Provider((ref) {
///   final controller = ScreenShakeController();
///   ref.onDispose(() => controller.dispose());
///   return controller;
/// });
///
/// class GameScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final shakeController = ref.watch(shakeControllerProvider);
///
///     return ScreenShake(
///       controller: shakeController,
///       child: YourContent(),
///     );
///   }
/// }
/// ```
///
/// CUSTOM INTENSITY:
/// ```dart
/// // Very subtle shake
/// _shakeController.shake(intensity: 1.0);
///
/// // Custom shake for special events
/// _shakeController.shake(intensity: 15.0);
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// BEST PRACTICES
/// ═══════════════════════════════════════════════════════════════════
///
/// DO:
/// ✓ Use light shake for minor feedback
/// ✓ Use medium shake for errors
/// ✓ Use heavy shake sparingly (big moments)
/// ✓ Combine with haptic feedback
/// ✓ Combine with sound effects
/// ✓ Dispose controller when done
///
/// DON'T:
/// ✗ Overuse (too much shaking is annoying)
/// ✗ Use for every interaction
/// ✗ Use very high intensity (makes users dizzy)
/// ✗ Shake continuously (give it time between shakes)
/// ✗ Rely on shake alone (combine with other feedback)
///
/// ACCESSIBILITY:
/// - Respect reduced motion preferences:
/// ```dart
/// void _shake() {
///   if (MediaQuery.of(context).disableAnimations) {
///     return; // Skip shake if animations disabled
///   }
///   _shakeController.shake();
/// }
/// ```
///
/// PERFORMANCE:
/// - Uses Transform (GPU-accelerated)
/// - No layout recalculation
/// - Lightweight animation
/// - Should maintain 60fps easily
///
/// WHEN TO USE:
/// ✓ Invalid game moves
/// ✓ Errors or warnings
/// ✓ Big wins or achievements
/// ✓ Critical events
/// ✓ Explosions or impacts (games)
///
/// WHEN NOT TO USE:
/// ✗ Normal interactions (too much)
/// ✗ Every button press
/// ✗ Scrolling or navigation
/// ✗ Background processes
/// ✗ Subtle UI changes
///
/// COMBINATIONS:
/// Shake works great with:
/// - Haptic feedback (HapticFeedback.vibrate())
/// - Sound effects (error sound, explosion sound)
/// - Visual effects (flash, color change)
/// - Particle effects (smoke, debris)
///
/// ═══════════════════════════════════════════════════════════════════
