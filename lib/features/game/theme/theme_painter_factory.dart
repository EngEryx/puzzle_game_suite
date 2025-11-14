import 'package:flutter/material.dart';
import '../../../core/models/game_color.dart';
import '../../../core/models/game_theme.dart';
import '../presentation/animations/pour_animation.dart';
import 'water_theme.dart';
import 'nuts_bolts_theme.dart';
import 'ball_theme.dart';
import 'test_tube_theme.dart';

/// Factory for creating theme-specific painters.
///
/// DESIGN PATTERN: Factory Pattern
///
/// This factory creates the appropriate painter based on the active theme.
/// It ensures:
/// 1. Single responsibility - each theme has its own painter
/// 2. Open/closed principle - new themes don't modify existing code
/// 3. Performance - painters are cached and reused
///
/// WHY FACTORY PATTERN?
/// - Centralizes theme painter creation logic
/// - Makes it easy to add new themes
/// - Ensures consistent painter instantiation
/// - Enables painter caching for performance
///
/// PERFORMANCE STRATEGY:
/// - Singleton painters per theme (avoid allocations)
/// - Lazy initialization (create only when needed)
/// - Painter reuse across frames
/// - Cache invalidation only on theme change
///
class ThemePainterFactory {
  /// Prevent instantiation - this is a factory class
  ThemePainterFactory._();

  /// Cache of theme painters (one per theme type)
  ///
  /// PERFORMANCE:
  /// Painters are stateless and can be reused across all containers
  /// of the same theme. This significantly reduces allocations.
  static final Map<ThemeType, ThemePainter> _painterCache = {};

  /// Create or retrieve a painter for the given theme.
  ///
  /// PARAMETERS:
  /// - [theme]: The game theme to create painter for
  ///
  /// RETURNS:
  /// - Cached or newly created ThemePainter instance
  ///
  /// PERFORMANCE:
  /// First call creates painter, subsequent calls reuse cached instance.
  static ThemePainter getPainter(GameTheme theme) {
    // Check cache first
    if (_painterCache.containsKey(theme.type)) {
      return _painterCache[theme.type]!;
    }

    // Create new painter based on theme type
    final painter = _createPainter(theme);

    // Cache for future use
    _painterCache[theme.type] = painter;

    return painter;
  }

  /// Internal method to create painter based on theme.
  static ThemePainter _createPainter(GameTheme theme) {
    return switch (theme.type) {
      ThemeType.water => WaterThemePainter(theme as WaterTheme),
      ThemeType.nutsBolts => NutsAndBoltsThemePainter(theme as NutsAndBoltsTheme),
      ThemeType.balls => BallThemePainter(theme as BallTheme),
      ThemeType.testTubes => TestTubeThemePainter(theme as TestTubeTheme),
    };
  }

  /// Clear painter cache.
  ///
  /// USE CASES:
  /// - Memory cleanup when switching away from game
  /// - Testing scenarios
  /// - Manual cache invalidation
  static void clearCache() {
    _painterCache.clear();
  }

  /// Clear specific theme from cache.
  static void clearTheme(ThemeType type) {
    _painterCache.remove(type);
  }

  /// Get cache size (for debugging).
  static int get cacheSize => _painterCache.length;
}

// ==============================================================================
// THEME PAINTER INTERFACE
// ==============================================================================

/// Abstract interface for theme-specific painters.
///
/// Each theme implements this interface to define how it renders:
/// - Container backgrounds
/// - Color segments
/// - Pour animations
/// - Special effects
///
/// DESIGN PHILOSOPHY:
/// This interface ensures all themes provide consistent rendering
/// capabilities while allowing theme-specific customization.
///
abstract class ThemePainter {
  /// The theme this painter renders
  final GameTheme theme;

  ThemePainter(this.theme);

  /// Paint the container background.
  ///
  /// This renders the empty container/tube structure.
  ///
  /// PARAMETERS:
  /// - [canvas]: Flutter canvas to paint on
  /// - [rect]: Container bounds
  void paintContainerBackground(Canvas canvas, Rect rect);

  /// Paint a color segment.
  ///
  /// This renders a single colored layer in the container.
  ///
  /// PARAMETERS:
  /// - [canvas]: Flutter canvas to paint on
  /// - [rect]: Segment bounds
  /// - [color]: Game color to render
  void paintColorSegment(Canvas canvas, Rect rect, GameColor color);

  /// Paint the container outline.
  ///
  /// This renders the container border/edges.
  ///
  /// PARAMETERS:
  /// - [canvas]: Flutter canvas to paint on
  /// - [rect]: Container bounds
  void paintContainerOutline(Canvas canvas, Rect rect);

  /// Paint pour animation effects.
  ///
  /// This renders in-flight liquid/objects during pour animations.
  ///
  /// PARAMETERS:
  /// - [canvas]: Flutter canvas to paint on
  /// - [containerRect]: Container bounds
  /// - [totalSize]: Total available size
  /// - [animation]: Pour animation state
  void paintPourAnimation(
    Canvas canvas,
    Rect containerRect,
    Size totalSize,
    PourAnimation animation,
  );

  /// Paint selection indicator.
  ///
  /// This renders the visual indicator for selected containers.
  ///
  /// PARAMETERS:
  /// - [canvas]: Flutter canvas to paint on
  /// - [rect]: Container bounds
  /// - [animationValue]: Animation progress (0.0 to 1.0)
  void paintSelectionIndicator(
    Canvas canvas,
    Rect rect,
    double animationValue,
  );
}

// ==============================================================================
// WATER THEME PAINTER
// ==============================================================================

/// Painter for water theme.
///
/// Renders translucent liquid with wave effects.
class WaterThemePainter extends ThemePainter {
  WaterThemePainter(WaterTheme theme) : super(theme);

  WaterTheme get waterTheme => theme as WaterTheme;

  @override
  void paintContainerBackground(Canvas canvas, Rect rect) {
    final backgroundPaint = Paint()
      ..color = theme.containerBackgroundColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, backgroundPaint);
  }

  @override
  void paintColorSegment(Canvas canvas, Rect rect, GameColor color) {
    // Use water-specific gradient
    final gradient = waterTheme.getColorGradient(color);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    // Add subtle wave effect on top surface
    if (waterTheme.renderWaves) {
      _paintWaveEffect(canvas, rect, color);
    }
  }

  void _paintWaveEffect(Canvas canvas, Rect rect, GameColor color) {
    final wavePaint = Paint()
      ..color = waterTheme.waveHighlightColor
      ..style = PaintingStyle.fill;

    // Draw subtle highlight at top
    final waveRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      rect.height * 0.1,
    );

    canvas.drawRect(waveRect, wavePaint);
  }

  @override
  void paintContainerOutline(Canvas canvas, Rect rect) {
    final outlinePaint = Paint()
      ..color = theme.containerOutlineColor
      ..strokeWidth = theme.containerOutlineWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, outlinePaint);
  }

  @override
  void paintPourAnimation(
    Canvas canvas,
    Rect containerRect,
    Size totalSize,
    PourAnimation animation,
  ) {
    // Water pour animation with droplets
    final gradient = waterTheme.getColorGradient(animation.color);
    final streamPaint = Paint()
      ..shader = gradient.createShader(containerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Simple pour stream for now
    // Full implementation would use complex path calculations
    // (similar to ContainerPainter's pour animations)
  }

  @override
  void paintSelectionIndicator(
    Canvas canvas,
    Rect rect,
    double animationValue,
  ) {
    final pulseOpacity = 0.7 + (animationValue * 0.3);

    // Glow effect
    for (int i = 3; i > 0; i--) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFEB3B).withOpacity(pulseOpacity * 0.3)
        ..strokeWidth = 3.0 + (i * 2.0)
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 2.0);

      final glowRect = rect.inflate(i * 1.5);
      final rrect = RRect.fromRectAndRadius(
        glowRect,
        Radius.circular(theme.containerBorderRadius),
      );

      canvas.drawRRect(rrect, glowPaint);
    }
  }
}

// ==============================================================================
// NUTS & BOLTS THEME PAINTER
// ==============================================================================

/// Painter for nuts and bolts theme.
///
/// Renders solid metallic bolts with threading.
class NutsAndBoltsThemePainter extends ThemePainter {
  NutsAndBoltsThemePainter(NutsAndBoltsTheme theme) : super(theme);

  NutsAndBoltsTheme get nutsTheme => theme as NutsAndBoltsTheme;

  @override
  void paintContainerBackground(Canvas canvas, Rect rect) {
    final backgroundPaint = Paint()
      ..color = theme.containerBackgroundColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, backgroundPaint);
  }

  @override
  void paintColorSegment(Canvas canvas, Rect rect, GameColor color) {
    // Use metallic gradient
    final gradient = nutsTheme.getColorGradient(color);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    // Add threading if enabled
    if (nutsTheme.renderThreads) {
      _paintThreading(canvas, rect);
    }
  }

  void _paintThreading(Canvas canvas, Rect rect) {
    final threadPaint = Paint()
      ..color = nutsTheme.threadColor
      ..strokeWidth = nutsTheme.threadWidth
      ..style = PaintingStyle.stroke;

    // Draw horizontal thread lines
    final positions = nutsTheme.getThreadPositions(rect);
    for (final y in positions) {
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        threadPaint,
      );
    }
  }

  @override
  void paintContainerOutline(Canvas canvas, Rect rect) {
    final outlinePaint = Paint()
      ..color = theme.containerOutlineColor
      ..strokeWidth = theme.containerOutlineWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, outlinePaint);
  }

  @override
  void paintPourAnimation(
    Canvas canvas,
    Rect containerRect,
    Size totalSize,
    PourAnimation animation,
  ) {
    // Bolts pour animation (faster, more mechanical)
    // Implementation would show bolts dropping
  }

  @override
  void paintSelectionIndicator(
    Canvas canvas,
    Rect rect,
    double animationValue,
  ) {
    final pulseOpacity = 0.7 + (animationValue * 0.3);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(pulseOpacity)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final borderRect = rect.inflate(2);
    final rrect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, borderPaint);
  }
}

// ==============================================================================
// BALL THEME PAINTER
// ==============================================================================

/// Painter for ball theme.
///
/// Renders glossy spherical balls.
class BallThemePainter extends ThemePainter {
  BallThemePainter(BallTheme theme) : super(theme);

  BallTheme get ballTheme => theme as BallTheme;

  @override
  void paintContainerBackground(Canvas canvas, Rect rect) {
    final backgroundPaint = Paint()
      ..color = theme.containerBackgroundColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, backgroundPaint);
  }

  @override
  void paintColorSegment(Canvas canvas, Rect rect, GameColor color) {
    // Calculate ball position and size
    final ballCenter = ballTheme.getBallCenter(rect);
    final ballRadius = ballTheme.getBallRadius(rect);

    // Draw ball shadow first
    _paintBallShadow(canvas, ballCenter, ballRadius);

    // Draw ball with spherical gradient
    final gradient = ballTheme.getSphericalGradient(color);
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: ballCenter, radius: ballRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ballCenter, ballRadius, paint);

    // Add specular highlight
    _paintBallHighlight(canvas, ballCenter, ballRadius);
  }

  void _paintBallShadow(Canvas canvas, Offset center, double radius) {
    final shadowGradient = ballTheme.getBallShadowGradient(center, radius);
    final shadowPaint = Paint()
      ..shader = shadowGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.8),
      )
      ..style = PaintingStyle.fill;

    final shadowCenter = ballTheme.getShadowPosition(center, radius);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: radius * 1.6,
        height: radius * 0.4,
      ),
      shadowPaint,
    );
  }

  void _paintBallHighlight(Canvas canvas, Offset center, double radius) {
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(ballTheme.highlightIntensity)
      ..style = PaintingStyle.fill;

    final highlightCenter = ballTheme.getShinePosition(center, radius);
    final highlightRadius = radius * ballTheme.highlightSize;

    canvas.drawCircle(highlightCenter, highlightRadius, highlightPaint);
  }

  @override
  void paintContainerOutline(Canvas canvas, Rect rect) {
    final outlinePaint = Paint()
      ..color = theme.containerOutlineColor
      ..strokeWidth = theme.containerOutlineWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, outlinePaint);
  }

  @override
  void paintPourAnimation(
    Canvas canvas,
    Rect containerRect,
    Size totalSize,
    PourAnimation animation,
  ) {
    // Ball drop animation with bounce
    // Implementation would show balls bouncing
  }

  @override
  void paintSelectionIndicator(
    Canvas canvas,
    Rect rect,
    double animationValue,
  ) {
    final pulseOpacity = 0.7 + (animationValue * 0.3);

    final glowPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(pulseOpacity * 0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final glowRect = rect.inflate(3);
    final rrect = RRect.fromRectAndRadius(
      glowRect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, glowPaint);
  }
}

// ==============================================================================
// TEST TUBE THEME PAINTER
// ==============================================================================

/// Painter for test tube theme.
///
/// Renders chemical solutions with bubbles and measurements.
class TestTubeThemePainter extends ThemePainter {
  TestTubeThemePainter(TestTubeTheme theme) : super(theme);

  TestTubeTheme get testTubeTheme => theme as TestTubeTheme;

  @override
  void paintContainerBackground(Canvas canvas, Rect rect) {
    final backgroundPaint = Paint()
      ..color = theme.containerBackgroundColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, backgroundPaint);

    // Paint measurement lines if enabled
    if (testTubeTheme.renderMeasurements) {
      _paintMeasurementLines(canvas, rect);
    }

    // Paint glass reflection if enabled
    if (testTubeTheme.renderGlassReflection) {
      _paintGlassReflection(canvas, rect);
    }
  }

  void _paintMeasurementLines(Canvas canvas, Rect rect) {
    final linePaint = Paint()
      ..color = testTubeTheme.measurementLineColor
      ..strokeWidth = testTubeTheme.measurementLineWidth
      ..style = PaintingStyle.stroke;

    final positions = testTubeTheme.getMeasurementLinePositions(rect);
    for (final y in positions) {
      // Draw short lines on sides
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.left + rect.width * 0.2, y),
        linePaint,
      );
      canvas.drawLine(
        Offset(rect.right - rect.width * 0.2, y),
        Offset(rect.right, y),
        linePaint,
      );
    }
  }

  void _paintGlassReflection(Canvas canvas, Rect rect) {
    final gradient = testTubeTheme.getGlassReflectionGradient(rect);
    final reflectionPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw reflection strip on left side
    final reflectionRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width * 0.3,
      rect.height,
    );

    canvas.drawRect(reflectionRect, reflectionPaint);
  }

  @override
  void paintColorSegment(Canvas canvas, Rect rect, GameColor color) {
    // Use chemical solution gradient
    final gradient = testTubeTheme.getColorGradient(color);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    // Add meniscus curve if this is the top segment
    if (testTubeTheme.renderMeniscus) {
      _paintMeniscus(canvas, rect, color);
    }

    // Add bubbles if enabled
    if (testTubeTheme.renderBubbles) {
      _paintBubbles(canvas, rect, color);
    }
  }

  void _paintMeniscus(Canvas canvas, Rect rect, GameColor color) {
    final meniscusPath = testTubeTheme.createMeniscusPath(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 0),
    );

    final meniscusPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(meniscusPath, meniscusPaint);
  }

  void _paintBubbles(Canvas canvas, Rect rect, GameColor color) {
    if (!testTubeTheme.shouldShowBubbles(color)) return;

    // Generate bubbles (using rect hashCode as seed for consistency)
    final bubbles = testTubeTheme.generateBubbles(rect, rect.hashCode);

    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      canvas.drawCircle(bubble.position, bubble.size, bubblePaint);
    }
  }

  @override
  void paintContainerOutline(Canvas canvas, Rect rect) {
    final outlinePaint = Paint()
      ..color = theme.containerOutlineColor
      ..strokeWidth = theme.containerOutlineWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, outlinePaint);
  }

  @override
  void paintPourAnimation(
    Canvas canvas,
    Rect containerRect,
    Size totalSize,
    PourAnimation animation,
  ) {
    // Chemical pour animation with bubbling effect
    // Implementation would show bubbling liquid stream
  }

  @override
  void paintSelectionIndicator(
    Canvas canvas,
    Rect rect,
    double animationValue,
  ) {
    final pulseOpacity = 0.7 + (animationValue * 0.3);

    // Scientific blue glow
    final glowPaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(pulseOpacity * 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final glowRect = rect.inflate(2);
    final rrect = RRect.fromRectAndRadius(
      glowRect,
      Radius.circular(theme.containerBorderRadius),
    );

    canvas.drawRRect(rrect, glowPaint);
  }
}
