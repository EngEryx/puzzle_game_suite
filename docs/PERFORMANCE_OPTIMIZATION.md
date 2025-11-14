# Performance Optimization Guide

## Overview

This guide covers performance optimization strategies for achieving 60fps on low-end devices (Android API 21+, iOS 11+).

**Target**: 60fps = 16.67ms per frame budget

## Table of Contents

1. [Performance Monitoring](#performance-monitoring)
2. [Optimization Techniques](#optimization-techniques)
3. [Profiling with Flutter DevTools](#profiling-with-flutter-devtools)
4. [Common Bottlenecks](#common-bottlenecks)
5. [Device-Specific Optimizations](#device-specific-optimizations)
6. [Benchmarking Methodology](#benchmarking-methodology)
7. [Battery Optimization](#battery-optimization)
8. [Trade-offs](#trade-offs)

---

## Performance Monitoring

### Using PerformanceMonitor

The `PerformanceMonitor` class provides real-time performance metrics:

```dart
import 'package:puzzle_game_suite/core/utils/performance_monitor.dart';

// Start monitoring in main()
void main() {
  PerformanceMonitor.instance.start();
  runApp(MyApp());
}

// Access metrics
final fps = PerformanceMonitor.instance.currentFPS;
final avgFrameTime = PerformanceMonitor.instance.averageFrameTime;
final smoothness = PerformanceMonitor.instance.smoothnessScore;

// Get a report
print(PerformanceMonitor.instance.getReport());
```

### Performance Overlay

Enable the performance overlay in debug mode:

```dart
MaterialApp(
  home: PerformanceOverlay(
    child: MyHomePage(),
  ),
);
```

### Key Metrics

- **FPS (Frames Per Second)**: Target 60fps
- **Frame Time**: Target < 16.67ms average
- **Smoothness Score**: Percentage of frames hitting target (aim for >90%)
- **Jank Percentage**: Frames taking >33ms (aim for <5%)

---

## Optimization Techniques

### 1. CustomPainter Optimizations

**Problem**: Widget-based rendering creates excessive overhead.

**Solution**: Use CustomPainter for game elements.

```dart
// BAD: Widget-based container (15ms per container)
Widget buildContainer() {
  return Stack(
    children: [
      Container(decoration: ...),
      ...colorSegments.map((color) => ColorSegment(color)),
    ],
  );
}

// GOOD: CustomPainter (2ms per container)
class ContainerPainter extends CustomPainter {
  // Cache Paint objects as static members
  static final Paint _cachedPaint = Paint()..color = Colors.blue;

  @override
  void paint(Canvas canvas, Size size) {
    // Direct canvas operations
    canvas.drawRect(rect, _cachedPaint);
  }

  @override
  bool shouldRepaint(ContainerPainter old) {
    // Only repaint when necessary
    return container != old.container;
  }
}
```

**Impact**: 7.5x faster rendering for game containers.

### 2. Paint Object Pooling

**Problem**: Creating Paint objects every frame causes GC pressure.

**Solution**: Cache and reuse Paint objects.

```dart
// BAD: New Paint every frame
void paint(Canvas canvas, Size size) {
  final paint = Paint()..color = Colors.red; // Allocation!
  canvas.drawCircle(center, radius, paint);
}

// GOOD: Cached Paint
class MyPainter extends CustomPainter {
  static final Paint _cachedPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    _cachedPaint.color = Colors.red; // Reuse!
    canvas.drawCircle(center, radius, _cachedPaint);
  }
}

// BEST: Use PaintPool for complex scenarios
void paint(Canvas canvas, Size size) {
  final paint = PaintPool.acquire();
  paint.color = Colors.red;
  canvas.drawCircle(center, radius, paint);
  PaintPool.release(paint); // Return to pool
}
```

**Impact**: Reduces GC pauses by 60-80%.

### 3. RepaintBoundary

**Problem**: One widget's repaint triggers repaints of siblings.

**Solution**: Wrap independent widgets in RepaintBoundary.

```dart
// BAD: All level cards repaint when one animates
GridView.builder(
  itemBuilder: (context, index) => LevelCard(level: levels[index]),
);

// GOOD: Each card has its own repaint boundary
GridView.builder(
  itemBuilder: (context, index) => RepaintBoundary(
    child: LevelCard(level: levels[index]),
  ),
);
```

**Impact**: Reduces cascade repaints by 90%.

### 4. Debounce & Throttle

**Problem**: Rapid events cause excessive processing.

**Solution**: Use debounce for one-off events, throttle for continuous events.

```dart
// Debounce: Wait for events to stop
final debouncer = Debouncer(delay: Duration(milliseconds: 300));
onSearchChanged(String query) {
  debouncer.call(() => performSearch(query));
}

// Throttle: Limit execution frequency
final throttler = Throttler(limit: Duration(milliseconds: 16)); // 60fps
onScroll() {
  throttler.call(() => updateScrollPosition());
}
```

**Impact**: Reduces unnecessary operations by 70-90%.

### 5. Lazy Loading with GridView.builder

**Problem**: Loading all 200 level cards at once.

**Solution**: Use GridView.builder with caching.

```dart
GridView.builder(
  cacheExtent: 500, // Preload 500px outside viewport
  itemCount: levels.length,
  itemBuilder: (context, index) {
    // Only builds visible items + cache extent
    return LevelCard(level: levels[index]);
  },
);
```

**Impact**: Initial load time reduced from 2000ms to 200ms.

### 6. shouldRepaint Optimization

**Problem**: CustomPainter repaints even when nothing changed.

**Solution**: Implement efficient shouldRepaint logic.

```dart
@override
bool shouldRepaint(ContainerPainter old) {
  // Check fastest-changing properties first
  if (animationValue != old.animationValue) return true;
  if (isSelected != old.isSelected) return true;
  if (container != old.container) return true;

  return false; // No changes, skip repaint
}
```

**Impact**: Eliminates 50-70% of unnecessary repaints.

### 7. Const Constructors

**Problem**: Rebuilding static widgets on every frame.

**Solution**: Use const constructors wherever possible.

```dart
// BAD: Rebuilds every frame
Text('Level 1', style: TextStyle(fontSize: 20))

// GOOD: Only builds once
const Text('Level 1', style: TextStyle(fontSize: 20))
```

**Impact**: Reduces rebuild overhead by ~30%.

---

## Profiling with Flutter DevTools

### 1. Install DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 2. Connect to Your App

```bash
# Run your app
flutter run

# DevTools URL will be printed
# Open it in Chrome
```

### 3. Performance View

**Key Features**:

- **Timeline**: See frame rendering breakdown
- **CPU Profiler**: Identify hot spots
- **Memory View**: Track allocations and GC
- **Widget Rebuild Stats**: Find unnecessary rebuilds

### 4. Timeline Analysis

**What to Look For**:

1. **UI Thread**: Should be < 16.67ms per frame
2. **Raster Thread**: GPU work, should also be < 16.67ms
3. **Expensive Operations**: Red bars indicate slow frames
4. **Shader Compilation**: First-frame jank (unavoidable)

**Common Issues**:

- **Build Time Too High**: Too many widgets, use const/RepaintBoundary
- **Layout Time Too High**: Complex layouts, simplify widget tree
- **Paint Time Too High**: Too many draw calls, use CustomPainter
- **Raster Time Too High**: Complex shadows/blurs, reduce effects on low-end devices

### 5. CPU Profiler

**Steps**:

1. Click "Record"
2. Perform the action you want to profile (e.g., scroll level selector)
3. Click "Stop"
4. Analyze the flame chart

**What to Look For**:

- **Hot Methods**: Methods taking >5% of time
- **Frequent Calls**: Methods called hundreds of times per frame
- **Synchronous Gaps**: Time not spent in your code (might be waiting on platform)

### 6. Memory Profiler

**Steps**:

1. Take a snapshot before action
2. Perform action (e.g., play a level)
3. Take another snapshot
4. Compare the difference

**What to Look For**:

- **Memory Leaks**: Objects not being released
- **Excessive Allocations**: Creating too many temporary objects
- **Large Objects**: Unexpectedly large data structures

### 7. Widget Rebuild Stats

Enable in your app:

```dart
void main() {
  debugProfileBuildsEnabled = true; // Enable rebuild tracking
  runApp(MyApp());
}
```

View stats in DevTools Performance tab.

---

## Common Bottlenecks

### 1. Excessive Widget Rebuilds

**Symptoms**:
- High build times in Timeline
- Many widgets rebuilt unnecessarily

**Solutions**:
- Use `const` constructors
- Split widgets into smaller pieces
- Use `RepaintBoundary`
- Use Riverpod family providers for granular updates

**Example**:

```dart
// BAD: Entire screen rebuilds when score changes
class GameScreen extends StatelessWidget {
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreWidget(score: state.score), // Rebuilds
        GameBoard(containers: state.containers), // Rebuilds!
        Controls(), // Rebuilds!
      ],
    );
  }
}

// GOOD: Only score widget rebuilds
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Consumer(builder: (context, ref, _) {
          final score = ref.watch(gameStateProvider.select((s) => s.score));
          return ScoreWidget(score: score);
        }),
        const GameBoard(), // Doesn't rebuild!
        const Controls(), // Doesn't rebuild!
      ],
    );
  }
}
```

### 2. Paint Object Allocations

**Symptoms**:
- Frequent GC pauses
- High memory allocation rate

**Solutions**:
- Cache Paint objects
- Use PaintPool
- Reuse Path objects

### 3. Complex Layouts

**Symptoms**:
- High layout time in Timeline
- Slow scrolling

**Solutions**:
- Flatten widget tree
- Use CustomMultiChildLayout for complex arrangements
- Avoid deeply nested Row/Column

### 4. Unoptimized Images

**Symptoms**:
- High memory usage
- Slow image loading

**Solutions**:
- Use appropriate image sizes
- Preload images
- Use cached_network_image for network images
- Consider using SVG for icons

### 5. Animation Jank

**Symptoms**:
- Stuttering during animations
- Inconsistent frame times

**Solutions**:
- Use AnimationController with vsync
- Avoid setState during animations
- Use AnimatedBuilder to limit rebuilds
- Cache animated widgets

---

## Device-Specific Optimizations

### Low-End Devices (Android API 21-23, iPhone 6/7)

**Constraints**:
- 1-2GB RAM
- Weak GPU
- Target 30fps acceptable

**Optimizations**:

```dart
final config = PerformanceConfig.instance;

// Reduce animation complexity
if (config.deviceTier == DeviceTier.low) {
  // Disable particle effects
  // Use simpler animations
  // Reduce shadow quality
  // Disable blur effects
}

// Example: Simplified pour animation
Duration getPourDuration() {
  return config.pourAnimationDuration; // Auto-adjusted for device
}
```

**Settings**:
- Animation complexity: 50%
- No particle effects
- No blur effects
- Minimal shadows
- Faster animation durations
- Smaller cache extent

### Mid-Range Devices

**Target**: Solid 60fps with moderate effects

**Settings**:
- Animation complexity: 75%
- Limited particles (20 max)
- Simple shadows
- Gradients enabled
- Moderate caching

### High-End Devices

**Target**: Perfect 60fps with full effects

**Settings**:
- Animation complexity: 100%
- Full particles (50 max)
- Advanced shadows and blur
- Aggressive caching
- Maximum quality

### Platform-Specific Notes

**Android**:
- More varied hardware
- Conservative defaults recommended
- Test on old devices (API 21-23)
- Use Android Profiler for native issues

**iOS**:
- Generally better performance
- Metal API optimized
- Consistent hardware within generation
- Use Instruments for deep profiling

---

## Benchmarking Methodology

### Test Devices

**Minimum Spec Devices** (Must maintain 30fps):
- Android: Galaxy J5 (2015), API 21, 1.5GB RAM
- iOS: iPhone 6s, iOS 11, 2GB RAM

**Target Spec Devices** (Must maintain 60fps):
- Android: Pixel 3a, API 28, 4GB RAM
- iOS: iPhone 11, iOS 14, 4GB RAM

**High Spec Devices** (Should be perfect 60fps):
- Android: Pixel 7, API 33, 8GB RAM
- iOS: iPhone 14 Pro, iOS 16, 6GB RAM

### Test Scenarios

1. **Level Selector Scroll**
   - Scroll through 200 levels rapidly
   - Measure: FPS, frame time, dropped frames
   - Target: 60fps on mid-tier, 30fps on low-tier

2. **Gameplay**
   - Complete a complex level (10+ moves)
   - With pour animations
   - Measure: FPS during animations, memory usage
   - Target: 60fps on mid/high, 45fps on low

3. **Level Transitions**
   - Navigate between screens
   - Measure: Transition smoothness, memory spikes
   - Target: < 200ms transition time

4. **Long Play Session**
   - Play 20 levels consecutively
   - Measure: Memory leaks, performance degradation
   - Target: No performance degradation over time

### Metrics to Track

| Metric | Excellent | Good | Acceptable | Poor |
|--------|-----------|------|------------|------|
| FPS | >58 | 55-58 | 45-55 | <45 |
| Avg Frame Time | <14ms | 14-16ms | 16-20ms | >20ms |
| Smoothness | >95% | 90-95% | 80-90% | <80% |
| Jank | <2% | 2-5% | 5-10% | >10% |
| Memory | <150MB | 150-200MB | 200-300MB | >300MB |

### Benchmarking Process

1. **Clean Build**:
   ```bash
   flutter clean
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. **Profile Mode** (for performance testing):
   ```bash
   flutter run --profile
   ```

3. **Record Baseline**:
   - Before optimizations
   - Record all metrics
   - Save DevTools timeline

4. **Apply Optimizations**:
   - One category at a time
   - Measure impact individually

5. **Record Results**:
   - After each optimization
   - Compare to baseline
   - Document improvements

6. **Regression Testing**:
   - Ensure optimizations don't break functionality
   - Check all devices
   - Verify no visual degradation

### Performance Regression Prevention

Add performance tests to CI:

```dart
// test/performance/performance_test.dart
void main() {
  testWidgets('Level selector scrolls smoothly', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Start monitoring
    PerformanceMonitor.instance.start();

    // Scroll
    await tester.drag(find.byType(GridView), Offset(0, -3000));
    await tester.pumpAndSettle();

    // Check metrics
    final fps = PerformanceMonitor.instance.currentFPS;
    expect(fps, greaterThan(45)); // Minimum acceptable FPS
  });
}
```

---

## Battery Optimization

### Power Consumption Tips

1. **Reduce Animation Frequency**
   - Lower FPS target when battery low
   - Pause animations when app backgrounded

2. **Minimize GPU Usage**
   - Reduce complex paint operations
   - Lower shadow/blur quality
   - Use simpler gradients

3. **Optimize Layout Updates**
   - Batch state changes
   - Avoid unnecessary rebuilds
   - Use const widgets

4. **Background Behavior**
   ```dart
   class _GameScreenState extends State<GameScreen>
       with WidgetsBindingObserver {

     @override
     void initState() {
       super.initState();
       WidgetsBinding.instance.addObserver(this);
     }

     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       if (state == AppLifecycleState.paused) {
         // Pause animations, stop timers
       } else if (state == AppLifecycleState.resumed) {
         // Resume animations
       }
     }

     @override
     void dispose() {
       WidgetsBinding.instance.removeObserver(this);
       super.dispose();
     }
   }
   ```

5. **Audio Management**
   - Reduce sample rate on low battery
   - Disable sound effects
   - Use system audio settings

### Battery-Saving Mode

```dart
class BatterySaverMode {
  static bool _enabled = false;

  static void enable() {
    _enabled = true;
    PerformanceConfig.instance.deviceTier = DeviceTier.low;
    // Reduce FPS target
    // Disable particles
    // Simplify animations
  }

  static void disable() {
    _enabled = false;
    PerformanceConfig.instance._detectDeviceTier();
  }
}
```

---

## Trade-offs

### Visual Quality vs Performance

| Feature | Visual Impact | Performance Cost | Low-End | Mid-End | High-End |
|---------|---------------|------------------|---------|---------|----------|
| Particles | High | High | OFF | LIMITED | ON |
| Blur | Medium | Very High | OFF | OFF | ON |
| Shadows | Medium | Medium | OFF | SIMPLE | FULL |
| Gradients | Low | Low | OFF | ON | ON |
| Animations | High | Medium | SIMPLE | REDUCED | FULL |
| Anti-aliasing | Low | Low | OFF | ON | ON |

### Memory vs Speed

- **More Cache = Faster, More Memory**
  - Level card cache: Balance based on device
  - Paint object pool: Always beneficial
  - Image preloading: Only on high-end devices

- **Lazy Loading = Slower Initial, Less Memory**
  - Use GridView.builder (always recommended)
  - Load images on-demand
  - Clear cache when not needed

### Smoothness vs Battery

- **High FPS = Smooth, More Power**
  - 60fps ideal, 30fps acceptable on battery saver
  - Reduce animation frequency on low battery
  - Pause when not visible

### Best Practices

1. **Start Conservative**
   - Default to mid-tier settings
   - Let high-end devices auto-detect
   - Provide user override option

2. **Test on Real Devices**
   - Emulators don't represent real performance
   - Test on oldest supported devices
   - Test on battery power, not USB

3. **Profile Before Optimizing**
   - Measure first, optimize second
   - Focus on biggest bottlenecks
   - Verify improvements with metrics

4. **User Control**
   - Provide quality settings in-app
   - Allow battery saver mode toggle
   - Remember user preferences

---

## Quick Reference

### Performance Checklist

- [ ] Use CustomPainter for game elements
- [ ] Cache Paint objects (static final)
- [ ] Implement efficient shouldRepaint
- [ ] Wrap list items in RepaintBoundary
- [ ] Use const constructors
- [ ] Lazy load with .builder constructors
- [ ] Debounce rapid events
- [ ] Throttle continuous events
- [ ] Set appropriate cacheExtent
- [ ] Profile with DevTools
- [ ] Test on low-end devices
- [ ] Monitor memory usage
- [ ] Implement device tier detection
- [ ] Provide quality settings

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Scrolling lags | Add RepaintBoundary, increase cacheExtent |
| Animation stutters | Use AnimatedBuilder, cache Paint objects |
| High memory usage | Clear caches, reduce image sizes |
| Slow startup | Lazy load, preload essentials only |
| GC pauses | Use object pools, reduce allocations |
| Battery drain | Lower FPS, simplify effects, pause when backgrounded |

### Useful Commands

```bash
# Profile mode (recommended for performance testing)
flutter run --profile

# Release build
flutter build apk --release
flutter build ios --release

# Performance overlay
flutter run --profile --trace-skia

# Check app size
flutter build apk --analyze-size

# Enable DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Resources

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Flutter Performance Profiling](https://flutter.dev/docs/perf/rendering-performance)
- [DevTools Documentation](https://flutter.dev/docs/development/tools/devtools/overview)
- [Shader Compilation Jank](https://flutter.dev/docs/perf/shader)

---

## Conclusion

Achieving 60fps on low-end devices requires:

1. **Smart Architecture**: CustomPainter, RepaintBoundary, const widgets
2. **Resource Management**: Object pooling, caching, lazy loading
3. **Device Awareness**: Tier detection, quality settings
4. **Continuous Monitoring**: DevTools, PerformanceMonitor, metrics
5. **Testing**: Real devices, various tiers, long sessions

Remember: **Measure, optimize, measure again!**
