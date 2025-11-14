import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/animation_constants.dart';

/// Subtle animated background with theme-specific patterns.
///
/// ═══════════════════════════════════════════════════════════════════
/// ANIMATED BACKGROUND: Ambient Visual Interest
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Adds subtle visual interest to screens:
/// - Moving gradients
/// - Floating particles
/// - Geometric patterns
/// - Theme-specific atmospheres
///
/// DESIGN PRINCIPLES:
/// 1. SUBTLE, NOT DISTRACTING:
///    - Low opacity (5-10%)
///    - Slow movement
///    - Doesn't interfere with content
///    - Can be easily overlooked
///
/// 2. PERFORMANCE:
///    - Toggleable for low-end devices
///    - Efficient rendering
///    - Low resource usage
///    - No impact on game logic
///
/// 3. THEME AWARE:
///    - Different patterns per theme
///    - Matches color scheme
///    - Enhances atmosphere
///
/// PSYCHOLOGY:
/// - Adds life and energy to static screens
/// - Creates subconscious interest
/// - Makes UI feel more polished
/// - Enhances "premium" feel
///
/// ═══════════════════════════════════════════════════════════════════
class AnimatedBackground extends StatefulWidget {
  /// Type of background animation
  final BackgroundType type;

  /// Whether animation is enabled
  final bool enabled;

  /// Child widget (content)
  final Widget child;

  /// Custom colors (null = use theme colors)
  final List<Color>? colors;

  const AnimatedBackground({
    super.key,
    this.type = BackgroundType.floatingBubbles,
    this.enabled = true,
    required this.child,
    this.colors,
  });

  /// Floating bubbles background
  factory AnimatedBackground.floatingBubbles({
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedBackground(
      type: BackgroundType.floatingBubbles,
      enabled: enabled,
      child: child,
    );
  }

  /// Moving gradient background
  factory AnimatedBackground.gradient({
    required Widget child,
    List<Color>? colors,
    bool enabled = true,
  }) {
    return AnimatedBackground(
      type: BackgroundType.gradient,
      enabled: enabled,
      colors: colors,
      child: child,
    );
  }

  /// Geometric patterns background
  factory AnimatedBackground.geometric({
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedBackground(
      type: BackgroundType.geometric,
      enabled: enabled,
      child: child,
    );
  }

  /// Particles background
  factory AnimatedBackground.particles({
    required Widget child,
    bool enabled = true,
  }) {
    return AnimatedBackground(
      type: BackgroundType.particles,
      enabled: enabled,
      child: child,
    );
  }

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        // Animated background layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _BackgroundPainter(
                  type: widget.type,
                  progress: _controller.value,
                  colors: widget.colors ?? _getThemeColors(context),
                ),
              );
            },
          ),
        ),
        // Content layer
        widget.child,
      ],
    );
  }

  /// Get colors based on theme
  List<Color> _getThemeColors(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return [
      primary.withOpacity(0.05),
      secondary.withOpacity(0.05),
    ];
  }
}

/// Types of background animations
enum BackgroundType {
  floatingBubbles,
  gradient,
  geometric,
  particles,
}

/// Custom painter for background effects
class _BackgroundPainter extends CustomPainter {
  final BackgroundType type;
  final double progress;
  final List<Color> colors;

  _BackgroundPainter({
    required this.type,
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case BackgroundType.floatingBubbles:
        _paintFloatingBubbles(canvas, size);
        break;
      case BackgroundType.gradient:
        _paintGradient(canvas, size);
        break;
      case BackgroundType.geometric:
        _paintGeometric(canvas, size);
        break;
      case BackgroundType.particles:
        _paintParticles(canvas, size);
        break;
    }
  }

  /// Paint floating bubbles
  void _paintFloatingBubbles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw several bubbles at different positions
    for (int i = 0; i < 5; i++) {
      final offset = (progress + i * 0.2) % 1.0;
      final x = (i * 0.25) * size.width;
      final y = size.height * (1.0 - offset);

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(x, y),
        size.width * 0.15,
        paint,
      );
    }
  }

  /// Paint moving gradient
  void _paintGradient(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Calculate gradient position based on progress
    final angle = progress * 2 * math.pi;
    final begin = Alignment(math.cos(angle), math.sin(angle));
    final end = Alignment(-math.cos(angle), -math.sin(angle));

    final gradient = LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  /// Paint geometric patterns
  void _paintGeometric(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw rotating hexagons
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final rotation = progress * 2 * math.pi + (i * math.pi / 3);
      paint.color = colors[i % colors.length];

      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = rotation + (j * math.pi / 3);
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  /// Paint particle field
  void _paintParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistency

    // Draw many small particles
    for (int i = 0; i < 20; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Add movement based on progress
      final x = (baseX + progress * size.width * 0.1) % size.width;
      final y = baseY;

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(x, y),
        2.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Preference key for enabling/disabling animated backgrounds
class AnimatedBackgroundPreference {
  static const String _key = 'animated_background_enabled';

  /// Check if animated backgrounds are enabled
  static bool isEnabled() {
    // TODO: Implement with shared_preferences
    // For now, default to true
    return true;
  }

  /// Set animated background preference
  static Future<void> setEnabled(bool enabled) async {
    // TODO: Implement with shared_preferences
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// BASIC USAGE:
/// ```dart
/// Scaffold(
///   body: AnimatedBackground.floatingBubbles(
///     child: YourContent(),
///   ),
/// )
/// ```
///
/// WITH SETTINGS:
/// ```dart
/// class MyScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final enabled = AnimatedBackgroundPreference.isEnabled();
///
///     return Scaffold(
///       body: AnimatedBackground.gradient(
///         enabled: enabled,
///         child: YourContent(),
///       ),
///     );
///   }
/// }
/// ```
///
/// CUSTOM COLORS:
/// ```dart
/// AnimatedBackground.gradient(
///   colors: [
///     Colors.blue.withOpacity(0.05),
///     Colors.purple.withOpacity(0.05),
///   ],
///   child: YourContent(),
/// )
/// ```
///
/// SETTINGS TOGGLE:
/// ```dart
/// class SettingsScreen extends StatefulWidget {
///   @override
///   State<SettingsScreen> createState() => _SettingsScreenState();
/// }
///
/// class _SettingsScreenState extends State<SettingsScreen> {
///   bool _animatedBg = AnimatedBackgroundPreference.isEnabled();
///
///   @override
///   Widget build(BuildContext context) {
///     return ListView(
///       children: [
///         SwitchListTile(
///           title: Text('Animated Backgrounds'),
///           subtitle: Text('May impact battery life'),
///           value: _animatedBg,
///           onChanged: (value) {
///             setState(() => _animatedBg = value);
///             AnimatedBackgroundPreference.setEnabled(value);
///           },
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// DIFFERENT BACKGROUNDS FOR DIFFERENT SCREENS:
/// ```dart
/// // Home screen
/// AnimatedBackground.floatingBubbles(
///   child: HomeScreen(),
/// )
///
/// // Game screen
/// AnimatedBackground.geometric(
///   child: GameScreen(),
/// )
///
/// // Results screen
/// AnimatedBackground.particles(
///   child: ResultsScreen(),
/// )
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// BEST PRACTICES
/// ═══════════════════════════════════════════════════════════════════
///
/// DO:
/// ✓ Keep opacity very low (5-10%)
/// ✓ Use slow animations (10-20 seconds)
/// ✓ Make it toggleable in settings
/// ✓ Test on low-end devices
/// ✓ Use for polish, not core functionality
///
/// DON'T:
/// ✗ Make it too prominent (distracting)
/// ✗ Use fast animations (nauseating)
/// ✗ Rely on it for important info
/// ✗ Use on every screen (overkill)
/// ✗ Forget to make it optional
///
/// PERFORMANCE TIPS:
/// - Use simple shapes (circles, lines)
/// - Limit particle count
/// - Use Transform instead of position changes
/// - Consider disabling on low-end devices
/// - Profile on real devices
///
/// ACCESSIBILITY:
/// - Respect reduced motion preferences:
/// ```dart
/// bool enabled = !MediaQuery.of(context).disableAnimations;
/// AnimatedBackground(
///   enabled: enabled,
///   child: content,
/// )
/// ```
///
/// WHEN TO USE:
/// ✓ Menu screens
/// ✓ Loading screens
/// ✓ Results screens
/// ✓ Settings screens
/// ✓ Non-critical UI
///
/// WHEN NOT TO USE:
/// ✗ During active gameplay
/// ✗ On low-end devices (optional)
/// ✗ Behind text-heavy content
/// ✗ In accessibility modes
/// ✗ When battery is low
///
/// TESTING:
/// - Test on multiple devices
/// - Check battery impact
/// - Verify it's truly subtle
/// - Ensure content is still readable
/// - Test with reduced motion on
///
/// ═══════════════════════════════════════════════════════════════════
