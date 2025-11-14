import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

/// Particle system for celebration effects like confetti and sparkles.
///
/// ═══════════════════════════════════════════════════════════════════
/// PARTICLE EFFECT: Visual Celebrations
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Creates satisfying particle effects for:
/// - Level completion (confetti)
/// - Perfect moves (sparkles)
/// - Achievements (fireworks)
/// - Big wins (explosions)
///
/// DESIGN PRINCIPLES:
/// 1. PERFORMANCE FIRST:
///    - Lightweight particles (simple shapes)
///    - Efficient rendering (CustomPainter)
///    - Auto-cleanup (dispose after animation)
///    - Target: <1ms per frame
///
/// 2. VISUAL IMPACT:
///    - Random colors for variety
///    - Physics-based motion (gravity, velocity)
///    - Rotation for dynamism
///    - Fade out naturally
///
/// 3. CONFIGURABILITY:
///    - Particle count adjustable
///    - Different particle types
///    - Customizable colors
///    - Speed and size controls
///
/// PSYCHOLOGY:
/// - Particles create excitement and celebration
/// - Movement draws attention to achievements
/// - Randomness prevents predictability/boredom
/// - Brief duration maintains impact without annoyance
///
/// ═══════════════════════════════════════════════════════════════════
class ParticleEffect extends StatefulWidget {
  /// Type of particle effect to display
  final ParticleType type;

  /// Number of particles to generate
  final int particleCount;

  /// Custom colors for particles (null = random vibrant colors)
  final List<Color>? colors;

  /// Duration of the effect
  final Duration duration;

  /// Callback when effect completes
  final VoidCallback? onComplete;

  const ParticleEffect({
    super.key,
    this.type = ParticleType.confetti,
    this.particleCount = 50,
    this.colors,
    this.duration = AnimationConstants.particleLifetime,
    this.onComplete,
  });

  /// Confetti explosion for celebrations
  factory ParticleEffect.confetti({
    int particleCount = 50,
    VoidCallback? onComplete,
  }) {
    return ParticleEffect(
      type: ParticleType.confetti,
      particleCount: particleCount,
      onComplete: onComplete,
    );
  }

  /// Sparkles for perfect moves
  factory ParticleEffect.sparkles({
    int particleCount = 20,
    VoidCallback? onComplete,
  }) {
    return ParticleEffect(
      type: ParticleType.sparkles,
      particleCount: particleCount,
      onComplete: onComplete,
    );
  }

  /// Fireworks for big achievements
  factory ParticleEffect.fireworks({
    int particleCount = 40,
    VoidCallback? onComplete,
  }) {
    return ParticleEffect(
      type: ParticleType.fireworks,
      particleCount: particleCount,
      onComplete: onComplete,
    );
  }

  /// Stars for victories
  factory ParticleEffect.stars({
    int particleCount = 15,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) {
    return ParticleEffect(
      type: ParticleType.stars,
      particleCount: particleCount,
      colors: colors ?? [Colors.amber, Colors.orange, Colors.yellow],
      onComplete: onComplete,
    );
  }

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Generate particles
    _particles = _generateParticles();

    // Start animation
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Generate particles based on type
  List<Particle> _generateParticles() {
    final random = math.Random();
    final colors = widget.colors ?? _getDefaultColors(widget.type);

    return List.generate(widget.particleCount, (index) {
      return Particle(
        type: widget.type,
        color: colors[random.nextInt(colors.length)],
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        velocityX: (random.nextDouble() - 0.5) *
            AnimationConstants.particleMaxSpeed,
        velocityY: -random.nextDouble() *
            AnimationConstants.particleMaxSpeed,
        size: AnimationConstants.particleMinSize +
            random.nextDouble() *
            (AnimationConstants.particleMaxSize -
             AnimationConstants.particleMinSize),
        rotation: random.nextDouble() * AnimationConstants.fullTurn,
        rotationSpeed: (random.nextDouble() - 0.5) *
            AnimationConstants.fullTurn,
      );
    });
  }

  /// Get default colors for particle type
  List<Color> _getDefaultColors(ParticleType type) {
    switch (type) {
      case ParticleType.confetti:
        return [
          Colors.red,
          Colors.blue,
          Colors.yellow,
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.cyan,
        ];
      case ParticleType.sparkles:
        return [
          Colors.yellow,
          Colors.amber,
          Colors.orange,
          Colors.white,
        ];
      case ParticleType.fireworks:
        return [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.white,
        ];
      case ParticleType.stars:
        return [
          Colors.amber,
          Colors.orange,
          Colors.yellow,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            type: widget.type,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Types of particle effects
enum ParticleType {
  confetti,
  sparkles,
  fireworks,
  stars,
}

/// Individual particle data
class Particle {
  final ParticleType type;
  final Color color;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final double rotation;
  final double rotationSpeed;

  const Particle({
    required this.type,
    required this.color,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  /// Calculate particle position at given progress (0.0 to 1.0)
  Offset getPosition(double progress, Size size) {
    // Apply gravity
    final gravity = 500.0; // pixels per second squared
    final time = progress * 2.0; // Scale time

    final x = startX * size.width + velocityX * time;
    final y = startY * size.height +
        velocityY * time +
        0.5 * gravity * time * time;

    return Offset(x, y);
  }

  /// Calculate particle opacity at given progress
  double getOpacity(double progress) {
    // Fade out in last 30% of animation
    if (progress < 0.7) return 1.0;
    return 1.0 - ((progress - 0.7) / 0.3);
  }

  /// Calculate particle rotation at given progress
  double getRotation(double progress) {
    return rotation + rotationSpeed * progress * 2.0;
  }
}

/// Custom painter for rendering particles
class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final ParticleType type;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(progress, size);
      final opacity = particle.getOpacity(progress);
      final rotation = particle.getRotation(progress);

      // Skip if particle is off-screen or fully transparent
      if (position.dy > size.height || opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      // Draw particle shape based on type
      switch (type) {
        case ParticleType.confetti:
          _drawConfetti(canvas, paint, particle.size);
          break;
        case ParticleType.sparkles:
          _drawSparkle(canvas, paint, particle.size);
          break;
        case ParticleType.fireworks:
          _drawFirework(canvas, paint, particle.size);
          break;
        case ParticleType.stars:
          _drawStar(canvas, paint, particle.size);
          break;
      }

      canvas.restore();
    }
  }

  /// Draw confetti rectangle
  void _drawConfetti(Canvas canvas, Paint paint, double size) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size,
      height: size * 2,
    );
    canvas.drawRect(rect, paint);
  }

  /// Draw sparkle star shape
  void _drawSparkle(Canvas canvas, Paint paint, double size) {
    final path = Path();
    // Four-pointed star
    path.moveTo(0, -size);
    path.lineTo(size * 0.2, -size * 0.2);
    path.lineTo(size, 0);
    path.lineTo(size * 0.2, size * 0.2);
    path.lineTo(0, size);
    path.lineTo(-size * 0.2, size * 0.2);
    path.lineTo(-size, 0);
    path.lineTo(-size * 0.2, -size * 0.2);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Draw firework circle
  void _drawFirework(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size, paint);
  }

  /// Draw five-pointed star
  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = math.cos(angle) * size;
      final y = math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      // Inner point
      final innerAngle = angle + math.pi / 5;
      final innerX = math.cos(innerAngle) * size * 0.4;
      final innerY = math.sin(innerAngle) * size * 0.4;
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// IN DIALOG OVERLAY:
/// ```dart
/// Stack(
///   children: [
///     // Your dialog content
///     AlertDialog(
///       content: Text('Level Complete!'),
///     ),
///     // Particle effect overlay
///     Positioned.fill(
///       child: IgnorePointer(
///         child: ParticleEffect.confetti(
///           onComplete: () => print('Confetti done!'),
///         ),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// ON BUTTON PRESS:
/// ```dart
/// void _onPerfectMove() {
///   setState(() {
///     _showSparkles = true;
///   });
///   Future.delayed(AnimationConstants.particleLifetime, () {
///     setState(() {
///       _showSparkles = false;
///     });
///   });
/// }
///
/// Stack(
///   children: [
///     // Your game board
///     GameBoard(),
///     // Conditional sparkles
///     if (_showSparkles)
///       Positioned.fill(
///         child: IgnorePointer(
///           child: ParticleEffect.sparkles(),
///         ),
///       ),
///   ],
/// )
/// ```
///
/// FULL SCREEN CELEBRATION:
/// ```dart
/// void _showVictory() {
///   showDialog(
///     context: context,
///     builder: (context) => Stack(
///       children: [
///         // Victory dialog
///         WinDialog(),
///         // Confetti overlay
///         Positioned.fill(
///           child: IgnorePointer(
///             child: ParticleEffect.confetti(
///               particleCount: 100,
///               onComplete: () => print('Celebration complete!'),
///             ),
///           ),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// PERFORMANCE NOTES
/// ═══════════════════════════════════════════════════════════════════
///
/// OPTIMIZATION:
/// - Uses CustomPainter (GPU-accelerated)
/// - Skips off-screen particles
/// - Simple shapes (rectangles, circles)
/// - No complex blending modes
/// - Auto-disposes after animation
///
/// TARGET PERFORMANCE:
/// - 50 particles: ~0.5ms per frame
/// - 100 particles: ~1ms per frame
/// - Should maintain 60fps on most devices
///
/// LOW-END DEVICE CONSIDERATIONS:
/// - Reduce particle count (25-30)
/// - Use simpler shapes (circles only)
/// - Shorter duration
/// - Consider skipping on very low-end devices
///
/// ACCESSIBILITY:
/// - Doesn't convey critical information
/// - Purely decorative
/// - Can be disabled for reduced motion
/// - Doesn't interfere with screen readers
///
/// ═══════════════════════════════════════════════════════════════════
