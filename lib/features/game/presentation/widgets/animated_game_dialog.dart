import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// A custom animated dialog wrapper for game-related dialogs.
/// Provides a fade-in and scale-up animation effect.
class AnimatedGameDialog extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedGameDialog({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0), // Animate from 0 to 1
      duration: duration,
      curve: Curves.easeOutBack, // A nice bouncy curve
      builder: (context, value, _) {
        // Clamp opacity to valid range [0.0, 1.0] to prevent assertion errors
        // easeOutBack can overshoot slightly above 1.0, which is fine for scale but not opacity
        final clampedOpacity = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: value, // Allow scale to overshoot for bounce effect
          child: Opacity(
            opacity: clampedOpacity, // But clamp opacity to valid range
            child: Dialog(
              backgroundColor: Colors.transparent, // Make dialog background transparent
              elevation: 0, // Remove default dialog elevation
              child: child,
            ),
          ),
        );
      },
    );
  }
}
