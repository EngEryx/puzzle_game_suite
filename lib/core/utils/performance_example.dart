import 'package:flutter/material.dart';
import 'performance_monitor.dart';
import 'optimization_utils.dart';
import '../../config/performance_config.dart';

/// Example integration of performance optimization utilities
///
/// This file demonstrates how to use the performance utilities together
/// for optimal app performance.
///
/// USAGE:
/// 1. Initialize in main()
/// 2. Use throughout app
/// 3. Monitor with DevTools
class PerformanceIntegrationExample {
  /// Initialize performance monitoring and configuration
  ///
  /// Call this in main() before runApp()
  static void initialize() {
    // 1. Start performance monitoring
    PerformanceMonitor.instance.start();

    // 2. Log device configuration
    PerformanceConfig.instance.logConfiguration();

    // 3. Listen to performance metrics (optional)
    PerformanceMonitor.instance.metricsStream.listen((metrics) {
      if (metrics.isPoor) {
        debugPrint('WARNING: Poor performance detected! FPS: ${metrics.fps}');
      }
    });
  }

  /// Example: Optimized widget with performance monitoring
  static Widget buildOptimizedScreen(BuildContext context) {
    return PerformanceMetricsOverlay(
      child: Scaffold(
        appBar: AppBar(title: const Text('Optimized Screen')),
        body: const OptimizedContent(),
      ),
    );
  }
}

/// Example optimized widget
class OptimizedContent extends StatefulWidget {
  const OptimizedContent({super.key});

  @override
  State<OptimizedContent> createState() => _OptimizedContentState();
}

class _OptimizedContentState extends State<OptimizedContent> {
  // Debouncer for search input
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  // Throttler for scroll events
  final _scrollThrottler = Throttler(limit: const Duration(milliseconds: 16));

  // Cache for expensive computations
  final _cache = CacheManager<String, Widget>(maxSize: 50);

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _scrollThrottler.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Throttle scroll updates to 60fps
    _scrollThrottler.call(() {
      // Handle scroll position updates
      debugPrint('Scroll position: ${_scrollController.offset}');
    });
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid excessive API calls
    _searchDebouncer.call(() {
      debugPrint('Performing search: $query');
      // Perform actual search here
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = PerformanceConfig.instance;

    return ListView.builder(
      controller: _scrollController,
      // Use device-specific cache extent
      cacheExtent: config.gridViewCacheExtent,
      itemCount: 100,
      itemBuilder: (context, index) {
        // Wrap each item in RepaintBoundary for performance
        return RepaintBoundary(
          key: ValueKey('item_$index'),
          child: _buildListItem(index),
        );
      },
    );
  }

  Widget _buildListItem(int index) {
    // Use cache for expensive computations
    return _cache.get('item_$index', () {
      // This expensive build only happens once per item
      return ListTile(
        title: Text('Item $index'),
        subtitle: const Text('Cached and optimized'),
      );
    });
  }
}

/// Example: Optimized CustomPainter using Paint pooling
class OptimizedPainter extends CustomPainter {
  final List<Offset> points;

  OptimizedPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Acquire Paint from pool instead of creating new one
    final paint = PaintPool.acquire();

    paint.color = Colors.blue;
    paint.strokeWidth = 2.0;
    paint.style = PaintingStyle.stroke;

    // Draw points
    final path = PathPool.acquire();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Return objects to pool for reuse
    PaintPool.release(paint);
    PathPool.release(path);
  }

  @override
  bool shouldRepaint(OptimizedPainter oldDelegate) {
    // Efficient comparison
    if (points.length != oldDelegate.points.length) return true;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != oldDelegate.points[i]) return true;
    }

    return false;
  }
}

/// Example: Device-aware feature toggling
class DeviceAwareFeatures {
  static Widget buildWithAdaptiveQuality(BuildContext context) {
    final config = PerformanceConfig.instance;

    return Column(
      children: [
        // Always show basic content
        const Text('Basic Content'),

        // Conditional particle effects based on device tier
        if (config.shouldEnableParticles)
          ParticleEffect(maxParticles: config.maxParticles),

        // Conditional blur effects
        if (config.shouldEnableBlur)
          const BlurEffect(),

        // Adaptive animation duration
        AnimatedContainer(
          duration: config.levelCardAnimationDuration,
          // ... other properties
        ),
      ],
    );
  }
}

/// Placeholder widgets for example
class ParticleEffect extends StatelessWidget {
  final int maxParticles;

  const ParticleEffect({super.key, required this.maxParticles});

  @override
  Widget build(BuildContext context) {
    return Text('Particles: $maxParticles');
  }
}

class BlurEffect extends StatelessWidget {
  const BlurEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Blur Effect Enabled');
  }
}

/// Example: Batch processing for multiple state updates
class BatchUpdateExample extends StatefulWidget {
  const BatchUpdateExample({super.key});

  @override
  State<BatchUpdateExample> createState() => _BatchUpdateExampleState();
}

class _BatchUpdateExampleState extends State<BatchUpdateExample> {
  final _batchProcessor = BatchProcessor();
  int _counter = 0;

  void _handleMultipleUpdates() {
    // Instead of calling setState multiple times:
    // setState(() => _counter++); // Bad!
    // setState(() => _counter++); // Bad!
    // setState(() => _counter++); // Bad!

    // Batch them together:
    for (int i = 0; i < 10; i++) {
      _batchProcessor.add(() {
        setState(() => _counter++);
      });
    }
    // Only one setState will execute, combining all updates
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Counter: $_counter'),
        ElevatedButton(
          onPressed: _handleMultipleUpdates,
          child: const Text('Batch Update'),
        ),
      ],
    );
  }
}

/// Example: Performance measurement
class PerformanceMeasurementExample {
  static Future<void> measureAsyncOperation() async {
    // Measure async operations
    final result = await PerformanceMonitor.measure(
      'Load Level Data',
      () async {
        // Simulate async operation
        await Future.delayed(const Duration(milliseconds: 100));
        return 'Level data loaded';
      },
    );

    debugPrint('Result: $result');
    // Output: [Load Level Data] took 100ms
  }

  static void measureSyncOperation() {
    // Measure sync operations
    final result = PerformanceMonitor.measureSync(
      'Calculate Level Score',
      () {
        // Simulate computation
        int score = 0;
        for (int i = 0; i < 1000000; i++) {
          score += i;
        }
        return score;
      },
    );

    debugPrint('Score: $result');
    // Output: [Calculate Level Score] took Xms
  }
}
