import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/game_color.dart';
import 'pour_animation.dart';

/// Manages pour animations with support for multiple simultaneous animations
/// and queued sequential animations.
///
/// ARCHITECTURE APPROACH:
///
/// This class acts as an animation coordinator, similar to:
/// - Spring Animation Controller (iOS)
/// - MotionLayout (Android)
/// - Framer Motion (React)
/// - GSAP Timeline (Web)
///
/// KEY RESPONSIBILITIES:
/// 1. Manage AnimationController lifecycle
/// 2. Track multiple active animations
/// 3. Queue animations for sequential execution
/// 4. Notify listeners of state changes
/// 5. Handle cleanup on dispose
///
/// PERFORMANCE CONSIDERATIONS:
///
/// Target: 60fps = 16.67ms per frame
/// Budget per animation: ~0.5ms
/// Maximum simultaneous: 10 animations (5ms total)
///
/// With Flutter's Ticker:
/// - Frame-synchronized updates (no jank)
/// - Hardware-accelerated rendering
/// - Efficient state management
///
/// THREADING MODEL:
///
/// All animations run on the UI thread using Ticker:
/// - Ticker syncs with VSYNC signal
/// - Callbacks fire just before frame render
/// - No need for separate animation thread
/// - Better performance than Timer-based animations
///
class PourAnimator extends ChangeNotifier {
  /// The ticker provider (usually from a StatefulWidget)
  final TickerProvider vsync;

  /// Duration for animations (can be configured)
  final Duration animationDuration;

  /// Curve for easing
  final Curve curve;

  /// The underlying Flutter AnimationController
  late final AnimationController _controller;

  /// Current active animations (can run simultaneously)
  final List<PourAnimation> _activeAnimations = [];

  /// Queued animations waiting to execute
  final List<_QueuedAnimation> _queuedAnimations = [];

  /// Callbacks to invoke when animations complete
  final Map<String, VoidCallback> _completionCallbacks = {};

  /// Whether animator has been disposed
  bool _disposed = false;

  /// Get current active animations (read-only)
  List<PourAnimation> get activeAnimations => List.unmodifiable(_activeAnimations);

  /// Get number of queued animations
  int get queuedCount => _queuedAnimations.length;

  /// Whether any animations are currently running
  bool get hasActiveAnimations => _activeAnimations.isNotEmpty;

  /// Whether there are animations in the queue
  bool get hasQueuedAnimations => _queuedAnimations.isNotEmpty;

  /// Whether animator is busy (active or queued animations)
  bool get isBusy => hasActiveAnimations || hasQueuedAnimations;

  /// Create a pour animator
  ///
  /// PARAMETERS:
  /// - [vsync]: Ticker provider from StatefulWidget
  /// - [animationDuration]: Default duration for animations
  /// - [curve]: Default easing curve
  ///
  /// USAGE:
  /// ```dart
  /// class GameScreenState extends State<GameScreen>
  ///     with SingleTickerProviderStateMixin {
  ///
  ///   late PourAnimator _animator;
  ///
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     _animator = PourAnimator(vsync: this);
  ///   }
  ///
  ///   @override
  ///   void dispose() {
  ///     _animator.dispose();
  ///     super.dispose();
  ///   }
  /// }
  /// ```
  PourAnimator({
    required this.vsync,
    this.animationDuration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  }) {
    _controller = AnimationController(
      vsync: vsync,
      duration: animationDuration,
    );

    // Listen to animation updates
    _controller.addListener(_onAnimationTick);

    // Listen to animation status changes
    _controller.addStatusListener(_onAnimationStatus);
  }

  /// Start a new pour animation
  ///
  /// MODES:
  /// 1. Immediate: Runs alongside other animations (parallel)
  /// 2. Queued: Waits for current animations to finish (sequential)
  ///
  /// PARAMETERS:
  /// - [fromContainerId]: Source container
  /// - [toContainerId]: Target container
  /// - [color]: Color being poured
  /// - [count]: Number of units
  /// - [queueIfBusy]: If true, queues when busy; if false, runs immediately
  /// - [onComplete]: Callback when animation finishes
  ///
  /// RETURNS:
  /// - Animation ID for tracking/cancellation
  ///
  /// USAGE:
  /// ```dart
  /// // Run immediately (parallel with other animations)
  /// animator.startAnimation(
  ///   fromContainerId: '1',
  ///   toContainerId: '2',
  ///   color: GameColor.red,
  ///   count: 2,
  ///   queueIfBusy: false,
  /// );
  ///
  /// // Queue for sequential execution
  /// animator.startAnimation(
  ///   fromContainerId: '2',
  ///   toContainerId: '3',
  ///   color: GameColor.blue,
  ///   count: 1,
  ///   queueIfBusy: true,
  ///   onComplete: () => print('Done!'),
  /// );
  /// ```
  String startAnimation({
    required String fromContainerId,
    required String toContainerId,
    required GameColor color,
    required int count,
    bool queueIfBusy = true,
    VoidCallback? onComplete,
  }) {
    if (_disposed) {
      throw StateError('Cannot start animation: animator disposed');
    }

    // Generate unique ID for this animation
    final animationId = _generateAnimationId(fromContainerId, toContainerId);

    // Create animation
    final animation = PourAnimation.start(
      fromContainerId: fromContainerId,
      toContainerId: toContainerId,
      color: color,
      count: count,
      durationMs: animationDuration.inMilliseconds,
      curve: curve,
    );

    // Store completion callback if provided
    if (onComplete != null) {
      _completionCallbacks[animationId] = onComplete;
    }

    // Decide whether to start immediately or queue
    if (queueIfBusy && hasActiveAnimations) {
      // Queue for later execution
      _queuedAnimations.add(_QueuedAnimation(
        animation: animation,
        id: animationId,
      ));
    } else {
      // Start immediately
      _startAnimationImmediate(animation);

      // If controller isn't running, start it
      if (!_controller.isAnimating) {
        _controller.forward(from: 0.0);
      }
    }

    notifyListeners();
    return animationId;
  }

  /// Start animation immediately without queueing
  void _startAnimationImmediate(PourAnimation animation) {
    _activeAnimations.add(animation);
  }

  /// Cancel a specific animation by ID
  ///
  /// Removes from active or queued animations.
  void cancelAnimation(String animationId) {
    // Remove from active animations
    _activeAnimations.removeWhere(
      (a) => _generateAnimationId(a.fromContainerId, a.toContainerId) == animationId,
    );

    // Remove from queued animations
    _queuedAnimations.removeWhere((q) => q.id == animationId);

    // Remove completion callback
    _completionCallbacks.remove(animationId);

    notifyListeners();
  }

  /// Cancel all animations (active and queued)
  void cancelAllAnimations() {
    _activeAnimations.clear();
    _queuedAnimations.clear();
    _completionCallbacks.clear();
    _controller.reset();
    notifyListeners();
  }

  /// Called on each animation frame (60fps)
  ///
  /// Updates all active animations based on controller value.
  void _onAnimationTick() {
    if (_disposed || _activeAnimations.isEmpty) return;

    // Calculate elapsed time since last frame
    final currentValue = _controller.value;

    // Update all active animations
    final updatedAnimations = <PourAnimation>[];
    final completedIds = <String>[];

    for (final animation in _activeAnimations) {
      // Update animation progress
      final updated = animation.copyWith(progress: currentValue);

      if (updated.isComplete) {
        // Mark as completed
        final id = _generateAnimationId(
          updated.fromContainerId,
          updated.toContainerId,
        );
        completedIds.add(id);
      } else {
        // Keep in active list
        updatedAnimations.add(updated);
      }
    }

    // Replace active animations with updated ones
    _activeAnimations.clear();
    _activeAnimations.addAll(updatedAnimations);

    // Invoke completion callbacks
    for (final id in completedIds) {
      final callback = _completionCallbacks.remove(id);
      callback?.call();
    }

    // Notify listeners to rebuild UI
    notifyListeners();
  }

  /// Called when animation status changes
  ///
  /// Handles animation completion and starting queued animations.
  void _onAnimationStatus(AnimationStatus status) {
    if (_disposed) return;

    if (status == AnimationStatus.completed) {
      // All active animations finished
      _activeAnimations.clear();

      // Check if there are queued animations
      if (_queuedAnimations.isNotEmpty) {
        // Start next batch of queued animations
        _startNextQueuedAnimation();
      } else {
        // Reset controller for next animation
        _controller.reset();
      }

      notifyListeners();
    }
  }

  /// Start the next queued animation
  void _startNextQueuedAnimation() {
    if (_queuedAnimations.isEmpty) return;

    // Take the first queued animation
    final queued = _queuedAnimations.removeAt(0);

    // Start it
    _startAnimationImmediate(queued.animation);

    // Restart controller
    _controller.forward(from: 0.0);
  }

  /// Generate a unique ID for animation tracking
  String _generateAnimationId(String fromId, String toId) {
    return '${fromId}_to_${toId}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Get animation for a specific container pair
  ///
  /// Useful for rendering - check if containers are currently animating.
  PourAnimation? getAnimation(String fromId, String toId) {
    return _activeAnimations.firstWhere(
      (a) => a.fromContainerId == fromId && a.toContainerId == toId,
      orElse: () => _activeAnimations.firstOrNull as PourAnimation,
    );
  }

  /// Check if a specific container is involved in any animation
  ///
  /// USAGE:
  /// ```dart
  /// if (animator.isContainerAnimating('1')) {
  ///   // Don't allow interaction with this container
  /// }
  /// ```
  bool isContainerAnimating(String containerId) {
    return _activeAnimations.any(
      (a) => a.fromContainerId == containerId || a.toContainerId == containerId,
    );
  }

  /// Wait for all animations to complete
  ///
  /// Returns a Future that completes when animator is idle.
  ///
  /// USAGE:
  /// ```dart
  /// await animator.waitForCompletion();
  /// print('All animations finished!');
  /// ```
  Future<void> waitForCompletion() async {
    if (!isBusy) return;

    // Create a completer that resolves when idle
    final completer = Completer<void>();

    void checkCompletion() {
      if (!isBusy) {
        removeListener(checkCompletion);
        completer.complete();
      }
    }

    addListener(checkCompletion);
    return completer.future;
  }

  /// Dispose of resources
  ///
  /// IMPORTANT: Always call this in your widget's dispose method!
  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;
    _controller.removeListener(_onAnimationTick);
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    _activeAnimations.clear();
    _queuedAnimations.clear();
    _completionCallbacks.clear();

    super.dispose();
  }

  /// Debug information
  String get debugInfo {
    return 'PourAnimator:\n'
        '  Active: ${_activeAnimations.length}\n'
        '  Queued: ${_queuedAnimations.length}\n'
        '  Controller: ${_controller.value.toStringAsFixed(2)}\n'
        '  Status: ${_controller.status}\n'
        '  Disposed: $_disposed';
  }
}

/// Internal class for queued animations
class _QueuedAnimation {
  final PourAnimation animation;
  final String id;

  _QueuedAnimation({
    required this.animation,
    required this.id,
  });
}

/// Extension methods for container-specific animations
extension PourAnimatorContainerExtensions on PourAnimator {
  /// Get all animations involving a specific container
  List<PourAnimation> getAnimationsForContainer(String containerId) {
    return activeAnimations.where((a) =>
      a.fromContainerId == containerId || a.toContainerId == containerId
    ).toList();
  }

  /// Get animations where container is the source
  List<PourAnimation> getOutgoingAnimations(String containerId) {
    return activeAnimations.where((a) =>
      a.fromContainerId == containerId
    ).toList();
  }

  /// Get animations where container is the target
  List<PourAnimation> getIncomingAnimations(String containerId) {
    return activeAnimations.where((a) =>
      a.toContainerId == containerId
    ).toList();
  }
}

/// Performance monitoring for animations
///
/// Tracks frame timing and helps identify performance issues.
class AnimationPerformanceMonitor {
  final List<double> _frameTimes = [];
  final int maxSamples;

  AnimationPerformanceMonitor({this.maxSamples = 60});

  /// Record a frame time
  void recordFrame(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);
    if (_frameTimes.length > maxSamples) {
      _frameTimes.removeAt(0);
    }
  }

  /// Average frame time
  double get averageFrameTime {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// Maximum frame time (worst case)
  double get maxFrameTime {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a > b ? a : b);
  }

  /// Minimum frame time (best case)
  double get minFrameTime {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a < b ? a : b);
  }

  /// Estimated FPS
  double get estimatedFps {
    if (averageFrameTime <= 0) return 0.0;
    return 1000.0 / averageFrameTime;
  }

  /// Whether performance is acceptable (>= 55fps)
  bool get isPerformanceGood => estimatedFps >= 55;

  /// Performance report
  String get report {
    return 'Animation Performance:\n'
        '  Average: ${averageFrameTime.toStringAsFixed(2)}ms\n'
        '  Min: ${minFrameTime.toStringAsFixed(2)}ms\n'
        '  Max: ${maxFrameTime.toStringAsFixed(2)}ms\n'
        '  FPS: ${estimatedFps.toStringAsFixed(1)}\n'
        '  Status: ${isPerformanceGood ? "Good" : "Needs optimization"}';
  }

  /// Clear recorded samples
  void clear() {
    _frameTimes.clear();
  }
}
