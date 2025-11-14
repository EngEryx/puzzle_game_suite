# Performance Optimization Integration Guide

## Quick Start

This guide shows you how to integrate the performance optimizations into your game.

### Step 1: Initialize in main()

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/utils/performance_monitor.dart';
import 'config/performance_config.dart';

void main() {
  // Initialize performance monitoring
  PerformanceMonitor.instance.start();

  // Log device configuration
  PerformanceConfig.instance.logConfiguration();

  runApp(const MyApp());
}
```

### Step 2: Add Performance Overlay (Debug Only)

Wrap your app with the performance metrics overlay:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Game Suite',
      home: PerformanceMetricsOverlay(
        child: HomeScreen(),
      ),
    );
  }
}
```

The overlay will only show in debug mode and displays:
- Current FPS
- Average frame time
- Smoothness percentage
- Color-coded status (green/orange/red)

### Step 3: Use Optimized Utilities

#### Debounce Search Input

```dart
class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _debouncer = Debouncer(delay: Duration(milliseconds: 300));

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.call(() {
      // Only called 300ms after user stops typing
      performSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(hintText: 'Search levels...'),
    );
  }
}
```

#### Throttle Scroll Events

```dart
class OptimizedListScreen extends StatefulWidget {
  @override
  State<OptimizedListScreen> createState() => _OptimizedListScreenState();
}

class _OptimizedListScreenState extends State<OptimizedListScreen> {
  final _scrollController = ScrollController();
  final _scrollThrottler = Throttler(limit: Duration(milliseconds: 16)); // 60fps

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollThrottler.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollThrottler.call(() {
      // Called at most once per 16ms (60fps)
      updateVisibleItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      cacheExtent: PerformanceConfig.instance.gridViewCacheExtent,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: MyListItem(index: index),
        );
      },
    );
  }
}
```

#### Use Paint Pooling in CustomPainter

```dart
class MyGamePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Acquire from pool instead of creating new Paint
    final paint = PaintPool.acquire();

    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );

    // Return to pool for reuse
    PaintPool.release(paint);
  }

  @override
  bool shouldRepaint(MyGamePainter oldDelegate) {
    return false; // Only repaint when needed
  }
}
```

### Step 4: Add Device-Aware Features

```dart
import 'config/performance_config.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = PerformanceConfig.instance;

    return Scaffold(
      body: Stack(
        children: [
          GameBoard(),

          // Conditional particle effects
          if (config.shouldEnableParticles)
            ParticleSystem(maxParticles: config.maxParticles),

          // Conditional blur
          if (config.shouldEnableBlur)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black12),
            ),
        ],
      ),
    );
  }
}
```

### Step 5: Optimize Animations

```dart
class AnimatedGameElement extends StatefulWidget {
  @override
  State<AnimatedGameElement> createState() => _AnimatedGameElementState();
}

class _AnimatedGameElementState extends State<AnimatedGameElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Use device-adjusted duration
    _controller = AnimationController(
      duration: PerformanceConfig.instance.pourAnimationDuration,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MyAnimatedPainter(
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}
```

## Advanced Usage

### Caching Expensive Computations

```dart
class LevelSelectorScreen extends StatefulWidget {
  @override
  State<LevelSelectorScreen> createState() => _LevelSelectorScreenState();
}

class _LevelSelectorScreenState extends State<LevelSelectorScreen> {
  final _cache = CacheManager<String, Widget>(maxSize: 50);

  Widget _buildLevelCard(Level level) {
    return _cache.get(level.id, () {
      // This expensive build only happens once per level
      return ExpensiveLevelCard(level: level);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemBuilder: (context, index) {
        return _buildLevelCard(levels[index]);
      },
    );
  }
}
```

### Batch State Updates

```dart
class GameController {
  final _batchProcessor = BatchProcessor();

  void processMultipleActions(List<GameAction> actions) {
    for (final action in actions) {
      _batchProcessor.add(() {
        applyAction(action);
      });
    }
    // All actions processed in single microtask
  }
}
```

### Performance Measurement

```dart
// Measure async operations
Future<void> loadLevel(String levelId) async {
  final levelData = await PerformanceMonitor.measure(
    'Load Level $levelId',
    () => levelRepository.loadLevel(levelId),
  );
  // Logs: [Load Level level_1] took 45ms
}

// Measure sync operations
int calculateScore(GameState state) {
  return PerformanceMonitor.measureSync(
    'Calculate Score',
    () => scoreCalculator.calculate(state),
  );
  // Logs: [Calculate Score] took 2ms
}
```

## Monitoring Performance

### Access Metrics Programmatically

```dart
// Get current metrics
final metrics = PerformanceMonitor.instance.metrics;

if (metrics.isPoor) {
  print('WARNING: Poor performance!');
  print('FPS: ${metrics.fps}');
  print('Smoothness: ${metrics.smoothnessScore}%');
}

// Listen to metrics stream
PerformanceMonitor.instance.metricsStream.listen((metrics) {
  if (metrics.jankPercentage > 10) {
    // High jank detected, maybe reduce quality
    PerformanceConfig.instance.deviceTier = DeviceTier.low;
  }
});

// Get performance report
print(PerformanceMonitor.instance.getReport());
```

### Manual Device Tier Override

```dart
// For testing or user preference
void setQualityPreference(String quality) {
  switch (quality) {
    case 'low':
      PerformanceConfig.instance.deviceTier = DeviceTier.low;
      break;
    case 'medium':
      PerformanceConfig.instance.deviceTier = DeviceTier.mid;
      break;
    case 'high':
      PerformanceConfig.instance.deviceTier = DeviceTier.high;
      break;
  }
}
```

## Best Practices Checklist

- [ ] Use `RepaintBoundary` for list items
- [ ] Cache `Paint` objects as `static final`
- [ ] Implement efficient `shouldRepaint` logic
- [ ] Use `const` constructors where possible
- [ ] Lazy load with `.builder` constructors
- [ ] Set appropriate `cacheExtent`
- [ ] Debounce rapid events (search, input)
- [ ] Throttle continuous events (scroll, resize)
- [ ] Use device-specific quality settings
- [ ] Measure performance with DevTools
- [ ] Monitor metrics in production
- [ ] Test on low-end devices

## Common Patterns

### Optimized GridView

```dart
GridView.builder(
  controller: _scrollController,
  cacheExtent: PerformanceConfig.instance.gridViewCacheExtent,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    childAspectRatio: 0.85,
  ),
  itemBuilder: (context, index) {
    return RepaintBoundary(
      key: ValueKey('item_$index'),
      child: MyGridItem(data: items[index]),
    );
  },
)
```

### Optimized CustomPainter

```dart
class OptimizedPainter extends CustomPainter {
  // Cache Paint objects
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;

  final MyData data;

  OptimizedPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // Reuse cached Paint
    _fillPaint.color = data.color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fillPaint);
  }

  @override
  bool shouldRepaint(OptimizedPainter old) {
    // Check cheapest comparisons first
    return data != old.data;
  }
}
```

### Optimized Animation

```dart
class OptimizedAnimation extends StatefulWidget {
  @override
  State<OptimizedAnimation> createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PerformanceConfig.instance.selectionPulseDuration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild what's necessary
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_animation.value * 0.5),
          child: child,
        );
      },
      child: const MyStaticWidget(), // Doesn't rebuild
    );
  }
}
```

## Troubleshooting

### FPS is low (<45)

1. Check Timeline in DevTools
2. Look for expensive builds
3. Add RepaintBoundary to isolate repaints
4. Cache Paint objects
5. Reduce animation complexity
6. Lower device tier setting

### High memory usage

1. Check Memory profiler
2. Clear caches when not needed
3. Reduce cache sizes
4. Release pooled objects
5. Check for memory leaks

### Animations are janky

1. Use AnimatedBuilder
2. Minimize rebuilds
3. Cache animated widgets
4. Use vsync properly
5. Reduce animation complexity on low-tier

### Scroll performance issues

1. Add RepaintBoundary
2. Increase cacheExtent
3. Throttle scroll events
4. Use lazy loading
5. Simplify list items

## Next Steps

1. Read `/docs/PERFORMANCE_OPTIMIZATION.md` for detailed guide
2. Profile your app with DevTools
3. Run benchmarks on test devices
4. Monitor metrics in production
5. Iterate and optimize

## Support

For more information:
- See `PERFORMANCE_SUMMARY.md` for overview
- See `PERFORMANCE_OPTIMIZATION.md` for deep dive
- Check inline code documentation
- Use Flutter DevTools for profiling
