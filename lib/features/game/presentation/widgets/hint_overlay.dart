import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/engine/puzzle_solver.dart';
import '../../../../shared/constants/animation_constants.dart';
import 'dart:math' as math;

/// Visual overlay that highlights suggested hint move.
///
/// ═══════════════════════════════════════════════════════════════════
/// HINT OVERLAY: Visual Hint Display
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Provides clear visual feedback for hint system:
/// - Highlights source and target containers
/// - Shows animated arrow/path between them
/// - Glowing effect to draw attention
/// - Auto-dismisses after timeout
/// - Tap-to-dismiss option
///
/// DESIGN PRINCIPLES:
///
/// 1. CLARITY:
///    - Clear visual distinction of hinted containers
///    - Arrow shows direction of move
///    - Non-intrusive but noticeable
///
/// 2. POLISH:
///    - Smooth animations (pulse, glow)
///    - Professional look
///    - Consistent with game aesthetic
///
/// 3. ACCESSIBILITY:
///    - High contrast highlights
///    - Clear visual indicators
///    - Tap anywhere to dismiss
///
/// 4. UX:
///    - Auto-dismiss prevents clutter
///    - Manual dismiss gives control
///    - Subtle enough to not annoy
///    - Clear enough to be helpful
///
/// ANIMATION PHASES:
///
/// 1. FADE IN (200ms):
///    - Overlay appears with opacity animation
///    - Highlights fade in
///
/// 2. PULSE (continuous):
///    - Container highlights pulse
///    - Arrow pulses
///    - Draws attention to hint
///
/// 3. FADE OUT (200ms):
///    - After 3 seconds or on tap
///    - Smooth dismissal
///
/// ═══════════════════════════════════════════════════════════════════
class HintOverlay extends ConsumerStatefulWidget {
  /// The hint to display
  final HintMove hint;

  /// Callback when overlay is dismissed
  final VoidCallback onDismiss;

  /// Container positions for drawing arrow
  final Map<String, Offset> containerPositions;

  /// Auto-dismiss duration (default: 3 seconds)
  final Duration autoDismissDuration;

  const HintOverlay({
    super.key,
    required this.hint,
    required this.onDismiss,
    required this.containerPositions,
    this.autoDismissDuration = const Duration(seconds: 3),
  });

  @override
  ConsumerState<HintOverlay> createState() => _HintOverlayState();
}

class _HintOverlayState extends ConsumerState<HintOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in/out animation
    _fadeController = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    _pulseController.repeat();

    // Auto-dismiss
    Future.delayed(widget.autoDismissDuration, _dismiss);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;

    await _fadeController.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  void _handleTap() {
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
              child: Stack(
                children: [
                  // Custom painter for arrow and highlights
                  CustomPaint(
                    size: Size.infinite,
                    painter: _HintPainter(
                      hint: widget.hint,
                      containerPositions: widget.containerPositions,
                      pulseAnimation: _pulseAnimation,
                      primaryColor: colorScheme.primary,
                    ),
                  ),

                  // Tap to dismiss hint
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap anywhere to dismiss',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for hint visualization.
class _HintPainter extends CustomPainter {
  final HintMove hint;
  final Map<String, Offset> containerPositions;
  final Animation<double> pulseAnimation;
  final Color primaryColor;

  _HintPainter({
    required this.hint,
    required this.containerPositions,
    required this.pulseAnimation,
    required this.primaryColor,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final fromPos = containerPositions[hint.fromId];
    final toPos = containerPositions[hint.toId];

    if (fromPos == null || toPos == null) return;

    // Draw highlights
    _drawContainerHighlight(canvas, fromPos, isSource: true);
    _drawContainerHighlight(canvas, toPos, isSource: false);

    // Draw arrow
    _drawArrow(canvas, fromPos, toPos);
  }

  /// Draw highlight around container.
  void _drawContainerHighlight(
    Canvas canvas,
    Offset position, {
    required bool isSource,
  }) {
    final pulseValue = pulseAnimation.value;
    final radius = 40.0 * pulseValue;

    // Outer glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(position, radius, glowPaint);

    // Inner ring
    final ringPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * pulseValue;

    canvas.drawCircle(position, radius - 5, ringPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: isSource ? 'FROM' : 'TO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, radius + 20),
    );
  }

  /// Draw animated arrow between containers.
  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final pulseValue = pulseAnimation.value;

    // Calculate arrow path
    final direction = to - from;
    final distance = direction.distance;
    final normalized = direction / distance;

    // Start and end points (offset from container centers)
    final start = from + normalized * 50;
    final end = to - normalized * 50;

    // Draw arrow shaft
    final shaftPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..strokeWidth = 4.0 * pulseValue
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, shaftPaint);

    // Draw arrow head
    final angle = math.atan2(direction.dy, direction.dx);
    final arrowSize = 20.0 * pulseValue;

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle - math.pi / 6),
        end.dy - arrowSize * math.sin(angle - math.pi / 6),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * math.cos(angle + math.pi / 6),
        end.dy - arrowSize * math.sin(angle + math.pi / 6),
      );

    final arrowPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 4.0 * pulseValue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(arrowPath, arrowPaint);

    // Draw pulsing dot at midpoint
    final midpoint = (start + end) / 2;
    final dotPaint = Paint()
      ..color = primaryColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(midpoint, 6.0 * pulseValue, dotPaint);
  }

  @override
  bool shouldRepaint(_HintPainter oldDelegate) {
    return oldDelegate.hint != hint ||
        oldDelegate.containerPositions != containerPositions ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Helper widget to get container positions for hint overlay.
///
/// USAGE:
/// ```dart
/// // In game board, wrap containers with this to track positions
/// HintPositionTracker(
///   containerId: container.id,
///   child: ContainerWidget(container),
/// )
/// ```
class HintPositionTracker extends ConsumerStatefulWidget {
  final String containerId;
  final Widget child;

  const HintPositionTracker({
    super.key,
    required this.containerId,
    required this.child,
  });

  @override
  ConsumerState<HintPositionTracker> createState() =>
      _HintPositionTrackerState();
}

class _HintPositionTrackerState extends ConsumerState<HintPositionTracker> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Update position after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  @override
  void didUpdateWidget(HintPositionTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update position on rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  void _updatePosition() {
    if (!mounted) return;

    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final center = position + Offset(size.width / 2, size.height / 2);

    // Store position in provider
    ref.read(containerPositionsProvider.notifier).state = {
      ...ref.read(containerPositionsProvider),
      widget.containerId: center,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}

/// Provider for container positions.
final containerPositionsProvider =
    StateProvider<Map<String, Offset>>((ref) => {});

/// ═══════════════════════════════════════════════════════════════════
/// HINT OVERLAY INTEGRATION NOTES
/// ═══════════════════════════════════════════════════════════════════
///
/// INTEGRATION:
///
/// 1. In game board, wrap containers with HintPositionTracker:
/// ```dart
/// GridView.builder(
///   itemBuilder: (context, index) {
///     final container = containers[index];
///     return HintPositionTracker(
///       containerId: container.id,
///       child: ContainerWidget(container),
///     );
///   },
/// )
/// ```
///
/// 2. Show overlay when hint is active:
/// ```dart
/// Stack(
///   children: [
///     GameBoard(),
///     if (currentHint != null)
///       HintOverlay(
///         hint: currentHint!,
///         containerPositions: containerPositions,
///         onDismiss: () => ref.read(hintProvider.notifier).clearHint(),
///       ),
///   ],
/// )
/// ```
///
/// 3. Request hint from button:
/// ```dart
/// onPressed: () async {
///   final result = await ref.read(hintProvider.notifier).requestHint(
///     containers: gameState.containers,
///     levelId: levelId,
///   );
///
///   if (!result.success) {
///     showSnackBar(result.errorMessage);
///   }
/// }
/// ```
///
/// ALTERNATIVE DESIGNS:
///
/// 1. SIMPLE HIGHLIGHT:
///    - Just highlight containers, no arrow
///    - Simpler implementation
///    - Less visual noise
///
/// 2. ANIMATED PATH:
///    - Show liquid pouring animation
///    - More engaging
///    - More complex implementation
///
/// 3. TOOLTIP STYLE:
///    - Small tooltip with arrow
///    - More subtle
///    - Less intrusive
///
/// CURRENT DESIGN RATIONALE:
/// - Arrow clearly shows direction
/// - Pulse animation draws attention
/// - Glow effect is visually appealing
/// - Auto-dismiss prevents clutter
/// - Tap-to-dismiss gives control
///
/// ═══════════════════════════════════════════════════════════════════
