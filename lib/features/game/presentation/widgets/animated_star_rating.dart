import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

/// A widget that animates the display of star ratings.
/// Stars appear one by one with a slight delay.
class AnimatedStarRating extends StatelessWidget {
  final int stars;
  final double starSize;
  final Color starColor;
  final Duration animationDuration;
  final Duration starDelay;

  const AnimatedStarRating({
    super.key,
    required this.stars,
    this.starSize = 48,
    this.starColor = Colors.amber,
    this.animationDuration = const Duration(milliseconds: 300),
    this.starDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isFilled = index < stars;
        final Duration delay = starDelay * index;

        return PlayAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: animationDuration,
          delay: delay,
          curve: Curves.easeOutBack,
          builder: (context, value, _) {
            // Clamp opacity to valid range [0.0, 1.0] to prevent assertion errors
            // easeOutBack curve can overshoot above 1.0 for bounce effect
            final clampedOpacity = value.clamp(0.0, 1.0);

            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: clampedOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    color: starColor,
                    size: starSize,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
