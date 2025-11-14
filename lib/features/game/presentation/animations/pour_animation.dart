import 'package:flutter/animation.dart';
import '../../../../core/models/game_color.dart';

/// Represents a single pour animation state.
///
/// DESIGN PHILOSOPHY:
///
/// This class is a pure data model representing the state of a pour animation
/// at any given moment. It's immutable and contains all information needed
/// to render the animation.
///
/// PHYSICS-INSPIRED ANIMATION:
///
/// We aim for realistic liquid pouring physics:
/// 1. Acceleration phase (liquid starts flowing)
/// 2. Constant velocity phase (steady pour)
/// 3. Deceleration phase (liquid stops)
///
/// This creates a natural, satisfying feel that players expect from
/// liquid physics in real life.
///
/// TIMING ANALYSIS:
///
/// Target: 60fps = 16.67ms per frame
/// Duration: 500ms = ~30 frames
/// Per-frame work: < 0.5ms for animation state updates
///
/// ANIMATION PRINCIPLES (Disney's 12 Principles Applied):
///
/// 1. EASE IN/OUT: Natural acceleration/deceleration
/// 2. ARC: Liquid follows parabolic arc when pouring
/// 3. TIMING: 400-600ms feels right for liquid
/// 4. ANTICIPATION: Slight delay before pour starts
/// 5. FOLLOW-THROUGH: Drip effect after main pour
///
class PourAnimation {
  /// Source container ID
  final String fromContainerId;

  /// Target container ID
  final String toContainerId;

  /// Color being poured
  final GameColor color;

  /// Number of units being transferred (1-4 typically)
  final int count;

  /// Animation progress (0.0 = start, 1.0 = complete)
  ///
  /// This is the raw linear progress value.
  /// Use [curvedProgress] for the eased value.
  final double progress;

  /// Total duration of the animation in milliseconds
  final int durationMs;

  /// Curve for easing the animation
  ///
  /// Default: easeInOut for natural liquid motion
  /// - Starts slow (liquid begins flowing)
  /// - Speeds up (steady pour)
  /// - Slows down (liquid stops)
  final Curve curve;

  /// Whether the animation is complete
  bool get isComplete => progress >= 1.0;

  /// Whether the animation has started
  bool get hasStarted => progress > 0.0;

  /// Progress with curve applied (0.0 to 1.0)
  ///
  /// This is the value to use for visual interpolation.
  /// It follows the easing curve for natural motion.
  double get curvedProgress {
    if (progress <= 0.0) return 0.0;
    if (progress >= 1.0) return 1.0;
    return curve.transform(progress);
  }

  /// Vertical progress for the pouring liquid (0.0 = top, 1.0 = bottom)
  ///
  /// Uses a faster curve for the downward motion to simulate gravity.
  double get verticalProgress {
    // Gravity accelerates the fall, so we use a different curve
    const gravityCurve = Curves.easeIn;
    return gravityCurve.transform(progress);
  }

  /// Horizontal arc progress (for the curved path)
  ///
  /// This creates the parabolic arc that liquid follows when pouring.
  /// Peak arc happens at 50% progress.
  double get arcProgress {
    final t = curvedProgress;
    // Parabolic function: y = -4(x - 0.5)^2 + 1
    // This creates an arc that peaks at 50% progress
    return -4 * (t - 0.5) * (t - 0.5) + 1;
  }

  /// Opacity of the pouring liquid (0.0 to 1.0)
  ///
  /// Fades in at start, solid during pour, fades out at end.
  double get opacity {
    if (progress < 0.1) {
      // Fade in during first 10%
      return progress / 0.1;
    } else if (progress > 0.9) {
      // Fade out during last 10%
      return (1.0 - progress) / 0.1;
    } else {
      // Fully opaque during middle 80%
      return 1.0;
    }
  }

  /// Create a pour animation
  ///
  /// PARAMETERS:
  /// - [fromContainerId]: Source container
  /// - [toContainerId]: Target container
  /// - [color]: Color being transferred
  /// - [count]: Number of units (affects animation intensity)
  /// - [progress]: Current progress (0.0 to 1.0)
  /// - [durationMs]: Animation duration (default: 500ms)
  /// - [curve]: Easing curve (default: easeInOut)
  ///
  /// RECOMMENDED DURATIONS:
  /// - 400ms: Fast, snappy (for quick games)
  /// - 500ms: Balanced, satisfying (recommended)
  /// - 600ms: Slow, deliberate (for relaxed play)
  const PourAnimation({
    required this.fromContainerId,
    required this.toContainerId,
    required this.color,
    required this.count,
    this.progress = 0.0,
    this.durationMs = 500,
    this.curve = Curves.easeInOut,
  });

  /// Create initial animation state (progress = 0)
  factory PourAnimation.start({
    required String fromContainerId,
    required String toContainerId,
    required GameColor color,
    required int count,
    int durationMs = 500,
    Curve curve = Curves.easeInOut,
  }) {
    return PourAnimation(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      color: color,
      count: count,
      progress: 0.0,
      durationMs: durationMs,
      curve: curve,
    );
  }

  /// Create a copy with updated progress
  ///
  /// This is the primary method for advancing the animation.
  /// Call this each frame with the new progress value.
  PourAnimation copyWith({
    String? fromContainerId,
    String? toContainerId,
    GameColor? color,
    int? count,
    double? progress,
    int? durationMs,
    Curve? curve,
  }) {
    return PourAnimation(
      fromContainerId: fromContainerId ?? this.fromContainerId,
      toContainerId: toContainerId ?? this.toContainerId,
      color: color ?? this.color,
      count: count ?? this.count,
      progress: progress ?? this.progress,
      durationMs: durationMs ?? this.durationMs,
      curve: curve ?? this.curve,
    );
  }

  /// Update progress based on elapsed time
  ///
  /// USAGE:
  /// ```dart
  /// final updatedAnimation = animation.updateWithElapsed(16.67); // One frame at 60fps
  /// ```
  ///
  /// PARAMETERS:
  /// - [elapsedMs]: Milliseconds elapsed since last update
  ///
  /// RETURNS:
  /// - New animation with updated progress
  PourAnimation updateWithElapsed(double elapsedMs) {
    final newProgress = (progress + (elapsedMs / durationMs)).clamp(0.0, 1.0);
    return copyWith(progress: newProgress);
  }

  /// Mark animation as complete
  PourAnimation complete() {
    return copyWith(progress: 1.0);
  }

  @override
  String toString() {
    return 'PourAnimation('
        'from: $fromContainerId, '
        'to: $toContainerId, '
        'color: $color, '
        'count: $count, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PourAnimation &&
        other.fromContainerId == fromContainerId &&
        other.toContainerId == toContainerId &&
        other.color == color &&
        other.count == count &&
        other.progress == progress &&
        other.durationMs == durationMs &&
        other.curve == curve;
  }

  @override
  int get hashCode {
    return Object.hash(
      fromContainerId,
      toContainerId,
      color,
      count,
      progress,
      durationMs,
      curve,
    );
  }
}

/// Extension methods for animation timing analysis
///
/// These help with performance monitoring and debugging.
extension PourAnimationAnalysis on PourAnimation {
  /// Elapsed time in milliseconds
  double get elapsedMs => progress * durationMs;

  /// Remaining time in milliseconds
  double get remainingMs => (1.0 - progress) * durationMs;

  /// Estimated frames at 60fps
  int get estimatedFrames => (durationMs / 16.67).round();

  /// Current frame number at 60fps
  int get currentFrame => (elapsedMs / 16.67).round();

  /// Remaining frames at 60fps
  int get remainingFrames => estimatedFrames - currentFrame;

  /// Whether we're in the first 25% of animation (acceleration phase)
  bool get isAccelerating => progress < 0.25;

  /// Whether we're in the middle 50% of animation (constant velocity)
  bool get isConstantVelocity => progress >= 0.25 && progress <= 0.75;

  /// Whether we're in the last 25% of animation (deceleration phase)
  bool get isDecelerating => progress > 0.75;

  /// Debug string with timing information
  String get debugTiming {
    return 'PourAnimation Timing:\n'
        '  Progress: ${(progress * 100).toStringAsFixed(1)}%\n'
        '  Elapsed: ${elapsedMs.toStringAsFixed(1)}ms\n'
        '  Remaining: ${remainingMs.toStringAsFixed(1)}ms\n'
        '  Frame: $currentFrame / $estimatedFrames\n'
        '  Phase: ${_getPhase()}';
  }

  String _getPhase() {
    if (isAccelerating) return 'Accelerating';
    if (isDecelerating) return 'Decelerating';
    if (isConstantVelocity) return 'Constant Velocity';
    return 'Unknown';
  }
}

/// Predefined animation configurations for different use cases
///
/// Use these for consistent animation feel across the game.
class PourAnimationConfig {
  /// Fast animation for quick gameplay (400ms)
  static const Duration fast = Duration(milliseconds: 400);

  /// Balanced animation for normal gameplay (500ms)
  static const Duration normal = Duration(milliseconds: 500);

  /// Slow animation for relaxed gameplay (600ms)
  static const Duration slow = Duration(milliseconds: 600);

  /// Quick animation for tutorials (300ms)
  static const Duration tutorial = Duration(milliseconds: 300);

  /// Smooth easing for natural liquid motion
  static const Curve smooth = Curves.easeInOut;

  /// Bouncy easing for playful feel
  static const Curve bouncy = Curves.elasticOut;

  /// Linear easing for mechanical feel
  static const Curve linear = Curves.linear;

  /// Fast easing for snappy feel
  static const Curve snappy = Curves.easeOut;

  /// Smooth entry, sharp exit
  static const Curve anticipation = Curves.easeIn;

  /// Create animation with fast preset
  static PourAnimation createFast({
    required String fromContainerId,
    required String toContainerId,
    required GameColor color,
    required int count,
  }) {
    return PourAnimation.start(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      color: color,
      count: count,
      durationMs: fast.inMilliseconds,
      curve: smooth,
    );
  }

  /// Create animation with normal preset
  static PourAnimation createNormal({
    required String fromContainerId,
    required String toContainerId,
    required GameColor color,
    required int count,
  }) {
    return PourAnimation.start(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      color: color,
      count: count,
      durationMs: normal.inMilliseconds,
      curve: smooth,
    );
  }

  /// Create animation with slow preset
  static PourAnimation createSlow({
    required String fromContainerId,
    required String toContainerId,
    required GameColor color,
    required int count,
  }) {
    return PourAnimation.start(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      color: color,
      count: count,
      durationMs: slow.inMilliseconds,
      curve: smooth,
    );
  }
}
