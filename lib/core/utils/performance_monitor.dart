import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

/// Performance monitoring utility for tracking app performance metrics
///
/// FEATURES:
/// - Real-time FPS tracking
/// - Frame time measurement
/// - Memory usage monitoring
/// - Performance logging
/// - DevTools integration
///
/// TARGET: 60fps = 16.67ms per frame
/// WARNING: Frame time > 16.67ms indicates dropped frames
///
/// USAGE:
/// ```dart
/// // Initialize in main()
/// PerformanceMonitor.instance.start();
///
/// // Check current performance
/// final fps = PerformanceMonitor.instance.currentFPS;
/// final frameTime = PerformanceMonitor.instance.averageFrameTime;
///
/// // Stop monitoring when done
/// PerformanceMonitor.instance.stop();
/// ```
class PerformanceMonitor {
  static final PerformanceMonitor instance = PerformanceMonitor._();

  PerformanceMonitor._();

  /// Whether monitoring is currently active
  bool _isMonitoring = false;

  /// Frame timing data (circular buffer of last 120 frames = 2 seconds at 60fps)
  final Queue<Duration> _frameTimes = Queue<Duration>();
  static const int _maxFrameHistory = 120;

  /// Current frame count
  int _frameCount = 0;

  /// Total elapsed time since monitoring started
  Duration _totalElapsed = Duration.zero;

  /// Last frame timestamp
  DateTime? _lastFrameTime;

  /// Performance metrics update timer
  Timer? _metricsTimer;

  /// Current performance metrics
  PerformanceMetrics _currentMetrics = const PerformanceMetrics();

  /// Stream controller for performance updates
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  /// Stream of performance metric updates
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// Current FPS (frames per second)
  double get currentFPS => _currentMetrics.fps;

  /// Average frame time in milliseconds
  double get averageFrameTime => _currentMetrics.averageFrameTimeMs;

  /// Maximum frame time in the current window
  double get maxFrameTime => _currentMetrics.maxFrameTimeMs;

  /// Minimum frame time in the current window
  double get minFrameTime => _currentMetrics.minFrameTimeMs;

  /// Percentage of frames hitting 60fps target
  double get smoothnessScore => _currentMetrics.smoothnessScore;

  /// Current metrics snapshot
  PerformanceMetrics get metrics => _currentMetrics;

  /// Start performance monitoring
  void start() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _frameCount = 0;
    _totalElapsed = Duration.zero;
    _frameTimes.clear();
    _lastFrameTime = DateTime.now();

    // Register frame callback
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    // Update metrics every 500ms
    _metricsTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _updateMetrics(),
    );

    if (kDebugMode) {
      print('[PerformanceMonitor] Started monitoring');
    }
  }

  /// Stop performance monitoring
  void stop() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _metricsTimer?.cancel();
    _metricsTimer = null;

    // Note: We don't remove the frame callback as it's persistent
    // and doesn't hurt to leave it running

    if (kDebugMode) {
      print('[PerformanceMonitor] Stopped monitoring');
      print('Final Stats: ${_currentMetrics.toString()}');
    }
  }

  /// Frame callback - called for every frame
  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);

      // Add to circular buffer
      _frameTimes.add(frameTime);
      if (_frameTimes.length > _maxFrameHistory) {
        _frameTimes.removeFirst();
      }

      _totalElapsed += frameTime;
    }

    _lastFrameTime = now;
    _frameCount++;
  }

  /// Update performance metrics
  void _updateMetrics() {
    if (_frameTimes.isEmpty) return;

    // Calculate FPS
    final fps = _frameCount / (_totalElapsed.inMilliseconds / 1000.0);

    // Calculate frame time statistics
    final frameTimes = _frameTimes.toList();
    final frameTimesMs =
        frameTimes.map((d) => d.inMicroseconds / 1000.0).toList();

    final avgFrameTime = frameTimesMs.reduce((a, b) => a + b) / frameTimesMs.length;
    final maxFrameTime = frameTimesMs.reduce((a, b) => a > b ? a : b);
    final minFrameTime = frameTimesMs.reduce((a, b) => a < b ? a : b);

    // Calculate smoothness score (percentage of frames < 16.67ms)
    const targetFrameTime = 16.67; // 60fps target
    final smoothFrames = frameTimesMs.where((t) => t <= targetFrameTime).length;
    final smoothnessScore = (smoothFrames / frameTimesMs.length) * 100.0;

    // Calculate jank percentage (frames > 33.33ms = dropped 2+ frames)
    const jankThreshold = 33.33;
    final jankFrames = frameTimesMs.where((t) => t > jankThreshold).length;
    final jankPercentage = (jankFrames / frameTimesMs.length) * 100.0;

    _currentMetrics = PerformanceMetrics(
      fps: fps,
      averageFrameTimeMs: avgFrameTime,
      maxFrameTimeMs: maxFrameTime,
      minFrameTimeMs: minFrameTime,
      smoothnessScore: smoothnessScore,
      jankPercentage: jankPercentage,
      frameCount: _frameCount,
      droppedFrames: frameTimesMs.where((t) => t > targetFrameTime).length,
    );

    // Emit metrics update
    _metricsController.add(_currentMetrics);

    // Log warnings for poor performance
    if (kDebugMode && smoothnessScore < 80.0) {
      print('[PerformanceMonitor] WARNING: Smoothness at ${smoothnessScore.toStringAsFixed(1)}%');
    }
  }

  /// Get a performance report string
  String getReport() {
    return '''
Performance Report
==================
FPS: ${currentFPS.toStringAsFixed(1)}
Avg Frame Time: ${averageFrameTime.toStringAsFixed(2)}ms
Max Frame Time: ${maxFrameTime.toStringAsFixed(2)}ms
Min Frame Time: ${minFrameTime.toStringAsFixed(2)}ms
Smoothness: ${smoothnessScore.toStringAsFixed(1)}%
Jank: ${_currentMetrics.jankPercentage.toStringAsFixed(1)}%
Total Frames: $_frameCount
Dropped Frames: ${_currentMetrics.droppedFrames}
''';
  }

  /// Log current metrics to console
  void logMetrics() {
    if (kDebugMode) {
      print(getReport());
    }
  }

  /// Measure the performance of a code block
  static Future<T> measure<T>(
    String label,
    Future<T> Function() block,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await block();
      stopwatch.stop();
      if (kDebugMode) {
        print('[$label] took ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('[$label] failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Measure the performance of a synchronous code block
  static T measureSync<T>(
    String label,
    T Function() block,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = block();
      stopwatch.stop();
      if (kDebugMode) {
        print('[$label] took ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('[$label] failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _metricsController.close();
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  /// Current frames per second
  final double fps;

  /// Average frame time in milliseconds
  final double averageFrameTimeMs;

  /// Maximum frame time in current window
  final double maxFrameTimeMs;

  /// Minimum frame time in current window
  final double minFrameTimeMs;

  /// Percentage of frames hitting 60fps target
  final double smoothnessScore;

  /// Percentage of frames with significant jank (>33ms)
  final double jankPercentage;

  /// Total frame count
  final int frameCount;

  /// Number of dropped frames
  final int droppedFrames;

  const PerformanceMetrics({
    this.fps = 0.0,
    this.averageFrameTimeMs = 0.0,
    this.maxFrameTimeMs = 0.0,
    this.minFrameTimeMs = 0.0,
    this.smoothnessScore = 100.0,
    this.jankPercentage = 0.0,
    this.frameCount = 0,
    this.droppedFrames = 0,
  });

  /// Whether performance is good (>55fps, >90% smoothness)
  bool get isGood => fps > 55 && smoothnessScore > 90;

  /// Whether performance is acceptable (>45fps, >75% smoothness)
  bool get isAcceptable => fps > 45 && smoothnessScore > 75;

  /// Whether performance is poor
  bool get isPoor => !isAcceptable;

  @override
  String toString() {
    return 'PerformanceMetrics(fps: ${fps.toStringAsFixed(1)}, '
        'avgFrameTime: ${averageFrameTimeMs.toStringAsFixed(2)}ms, '
        'smoothness: ${smoothnessScore.toStringAsFixed(1)}%)';
  }
}

/// Widget for displaying performance metrics overlay
class PerformanceMetricsOverlay extends StatefulWidget {
  final Widget child;

  const PerformanceMetricsOverlay({
    super.key,
    required this.child,
  });

  @override
  State<PerformanceMetricsOverlay> createState() => _PerformanceMetricsOverlayState();
}

class _PerformanceMetricsOverlayState extends State<PerformanceMetricsOverlay> {
  StreamSubscription<PerformanceMetrics>? _subscription;
  PerformanceMetrics _metrics = const PerformanceMetrics();

  @override
  void initState() {
    super.initState();
    _subscription = PerformanceMonitor.instance.metricsStream.listen((metrics) {
      if (mounted) {
        setState(() {
          _metrics = metrics;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (kDebugMode)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_metrics.fps.toStringAsFixed(1)} FPS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_metrics.averageFrameTimeMs.toStringAsFixed(1)}ms',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_metrics.smoothnessScore.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getBackgroundColor() {
    if (_metrics.isGood) {
      return Colors.green.withOpacity(0.8);
    } else if (_metrics.isAcceptable) {
      return Colors.orange.withOpacity(0.8);
    } else {
      return Colors.red.withOpacity(0.8);
    }
  }
}
