import 'package:flutter/material.dart';

/// Standard animation constants for consistent game feel across the app.
///
/// ═══════════════════════════════════════════════════════════════════
/// ANIMATION CONSTANTS: Consistency & Game Feel
/// ═══════════════════════════════════════════════════════════════════
///
/// PURPOSE:
/// Centralizes all animation timing and physics parameters for:
/// - Consistent feel across all animations
/// - Easy global adjustment of game pace
/// - Professional polish through standardization
/// - Performance optimization through reuse
///
/// DESIGN PRINCIPLES:
/// 1. THREE-TIER TIMING:
///    - Fast: Quick feedback (100-200ms)
///    - Normal: Standard transitions (300-400ms)
///    - Slow: Emphasis animations (500-800ms)
///
/// 2. SEMANTIC NAMING:
///    - Duration names describe when to use them
///    - Curve names describe the feel
///
/// 3. PLATFORM AWARE:
///    - Durations work well on 60fps and 120fps displays
///    - Physics feel natural on all devices
///
/// PSYCHOLOGY:
/// - Faster animations feel responsive
/// - Slower animations draw attention
/// - Consistent timing creates predictability
/// - Spring physics feel organic and playful
///
/// ═══════════════════════════════════════════════════════════════════
class AnimationConstants {
  AnimationConstants._(); // Prevent instantiation

  // ═══════════════════════════════════════════════════════════════════
  // DURATIONS: Standard timing for animations
  // ═══════════════════════════════════════════════════════════════════

  /// Ultra-fast: Immediate feedback (button press, ripples)
  static const Duration ultraFast = Duration(milliseconds: 100);

  /// Fast: Quick state changes (hover, selection)
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal: Standard UI transitions (dialogs, page transitions)
  static const Duration normal = Duration(milliseconds: 300);

  /// Medium: Noticeable transitions (slide-ins, scale effects)
  static const Duration medium = Duration(milliseconds: 400);

  /// Slow: Emphasis animations (celebrations, major events)
  static const Duration slow = Duration(milliseconds: 600);

  /// Very slow: Special celebrations (level complete, achievements)
  static const Duration verySlow = Duration(milliseconds: 800);

  /// Extra slow: Epic moments (game complete, high scores)
  static const Duration extraSlow = Duration(milliseconds: 1000);

  // ═══════════════════════════════════════════════════════════════════
  // CURVES: Standard easing functions
  // ═══════════════════════════════════════════════════════════════════

  /// Smooth ease: General purpose (most animations)
  static const Curve ease = Curves.easeInOut;

  /// Ease out: Decelerating (entrance animations, appearance)
  static const Curve easeOut = Curves.easeOut;

  /// Ease in: Accelerating (exit animations, disappearance)
  static const Curve easeIn = Curves.easeIn;

  /// Ease out cubic: Smooth deceleration (dialog entrances)
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Ease in cubic: Smooth acceleration (dialog exits)
  static const Curve easeInCubic = Curves.easeInCubic;

  /// Bounce: Playful overshoot (success states, celebrations)
  static const Curve bounce = Curves.elasticOut;

  /// Spring: Natural physics (buttons, interactive elements)
  static const Curve spring = Curves.easeOutBack;

  /// Sharp: Quick snap (errors, warnings)
  static const Curve sharp = Curves.easeOutQuart;

  /// Linear: Constant speed (loading, progress)
  static const Curve linear = Curves.linear;

  // ═══════════════════════════════════════════════════════════════════
  // SPRING PHYSICS: For natural, physics-based animations
  // ═══════════════════════════════════════════════════════════════════

  /// Gentle spring: Subtle bounce (buttons, cards)
  ///
  /// PARAMETERS:
  /// - mass: 1.0 (standard)
  /// - stiffness: 100.0 (moderate)
  /// - damping: 10.0 (well-damped, minimal oscillation)
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 100.0,
    damping: 10.0,
  );

  /// Bouncy spring: Noticeable bounce (celebrations, success)
  ///
  /// PARAMETERS:
  /// - mass: 1.0 (standard)
  /// - stiffness: 180.0 (stiff)
  /// - damping: 12.0 (some oscillation)
  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 12.0,
  );

  /// Snappy spring: Quick, tight bounce (quick actions)
  ///
  /// PARAMETERS:
  /// - mass: 0.5 (light)
  /// - stiffness: 200.0 (very stiff)
  /// - damping: 15.0 (well-controlled)
  static const SpringDescription snappySpring = SpringDescription(
    mass: 0.5,
    stiffness: 200.0,
    damping: 15.0,
  );

  /// Wobbly spring: Exaggerated bounce (big wins, achievements)
  ///
  /// PARAMETERS:
  /// - mass: 1.5 (heavy)
  /// - stiffness: 150.0 (moderate)
  /// - damping: 8.0 (under-damped, lots of oscillation)
  static const SpringDescription wobblySpring = SpringDescription(
    mass: 1.5,
    stiffness: 150.0,
    damping: 8.0,
  );

  // ═══════════════════════════════════════════════════════════════════
  // TIMING CONSTANTS: For coordinating complex animations
  // ═══════════════════════════════════════════════════════════════════

  /// Stagger delay: Time between staggered animations
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Stagger delay (long): For dramatic reveals
  static const Duration staggerDelayLong = Duration(milliseconds: 100);

  /// Particle lifetime: How long particles stay visible
  static const Duration particleLifetime = Duration(milliseconds: 2000);

  /// Shake duration: How long screen shake lasts
  static const Duration shakeDuration = Duration(milliseconds: 500);

  /// Pulse interval: For pulsing/breathing animations
  static const Duration pulseInterval = Duration(milliseconds: 1500);

  // ═══════════════════════════════════════════════════════════════════
  // SCALE FACTORS: For consistent sizing in animations
  // ═══════════════════════════════════════════════════════════════════

  /// Button press scale: How much buttons shrink on press
  static const double buttonPressScale = 0.95;

  /// Button hover scale: How much buttons grow on hover
  static const double buttonHoverScale = 1.05;

  /// Pop scale: Maximum scale for pop-in animations
  static const double popScale = 1.1;

  /// Bounce overshoot: How far past target bounce animations go
  static const double bounceOvershoot = 1.15;

  // ═══════════════════════════════════════════════════════════════════
  // OPACITY VALUES: For fade animations
  // ═══════════════════════════════════════════════════════════════════

  /// Disabled opacity: For disabled UI elements
  static const double disabledOpacity = 0.4;

  /// Hover opacity: For hover effects
  static const double hoverOpacity = 0.8;

  /// Subtle opacity: For subtle overlays
  static const double subtleOpacity = 0.1;

  /// Medium opacity: For standard overlays
  static const double mediumOpacity = 0.5;

  // ═══════════════════════════════════════════════════════════════════
  // ROTATION VALUES: For rotation animations
  // ═══════════════════════════════════════════════════════════════════

  /// Quarter turn: 90 degrees in radians
  static const double quarterTurn = 1.5708; // π/2

  /// Half turn: 180 degrees in radians
  static const double halfTurn = 3.14159; // π

  /// Full turn: 360 degrees in radians
  static const double fullTurn = 6.28319; // 2π

  // ═══════════════════════════════════════════════════════════════════
  // PARTICLE SYSTEM CONSTANTS
  // ═══════════════════════════════════════════════════════════════════

  /// Confetti particle count: For celebration effects
  static const int confettiCount = 50;

  /// Sparkle particle count: For perfect moves
  static const int sparkleCount = 20;

  /// Particle min size: Minimum particle size
  static const double particleMinSize = 4.0;

  /// Particle max size: Maximum particle size
  static const double particleMaxSize = 12.0;

  /// Particle min speed: Minimum particle velocity
  static const double particleMinSpeed = 100.0;

  /// Particle max speed: Maximum particle velocity
  static const double particleMaxSpeed = 300.0;

  // ═══════════════════════════════════════════════════════════════════
  // SCREEN SHAKE CONSTANTS
  // ═══════════════════════════════════════════════════════════════════

  /// Light shake intensity: For minor feedback
  static const double lightShakeIntensity = 2.0;

  /// Medium shake intensity: For errors
  static const double mediumShakeIntensity = 5.0;

  /// Heavy shake intensity: For big events
  static const double heavyShakeIntensity = 10.0;
}

/// ═══════════════════════════════════════════════════════════════════
/// USAGE EXAMPLES
/// ═══════════════════════════════════════════════════════════════════
///
/// SIMPLE FADE:
/// ```dart
/// AnimatedOpacity(
///   opacity: isVisible ? 1.0 : 0.0,
///   duration: AnimationConstants.fast,
///   curve: AnimationConstants.easeOut,
///   child: child,
/// )
/// ```
///
/// BUTTON PRESS:
/// ```dart
/// AnimatedScale(
///   scale: isPressed
///     ? AnimationConstants.buttonPressScale
///     : 1.0,
///   duration: AnimationConstants.ultraFast,
///   curve: AnimationConstants.spring,
///   child: button,
/// )
/// ```
///
/// STAGGERED LIST:
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return AnimatedSlide(
///       duration: AnimationConstants.medium,
///       curve: AnimationConstants.easeOut,
///       offset: Offset(0, 0),
///       child: child,
///     );
///   },
/// )
/// ```
///
/// SPRING ANIMATION:
/// ```dart
/// final controller = AnimationController.unbounded(vsync: this);
/// final spring = SpringSimulation(
///   AnimationConstants.bouncySpring,
///   0.0, // start
///   1.0, // end
///   0.0, // velocity
/// );
/// controller.animateWith(spring);
/// ```
///
/// ═══════════════════════════════════════════════════════════════════
/// BEST PRACTICES
/// ═══════════════════════════════════════════════════════════════════
///
/// DO:
/// ✓ Use these constants for ALL animations
/// ✓ Choose semantic names (fast, slow) over raw numbers
/// ✓ Combine duration + curve for best results
/// ✓ Test on multiple devices and frame rates
/// ✓ Consider accessibility (respect reduced motion)
///
/// DON'T:
/// ✗ Create one-off durations (use these constants)
/// ✗ Use linear curves for UI (feels robotic)
/// ✗ Make animations too slow (users get impatient)
/// ✗ Overuse bounce (can feel unprofessional)
/// ✗ Forget to dispose animation controllers
///
/// PERFORMANCE:
/// - Shorter animations = better perceived performance
/// - Opacity/Transform animations are GPU-accelerated
/// - Avoid animating size/position (expensive)
/// - Use Transform instead of changing layout properties
///
/// ACCESSIBILITY:
/// - Respect MediaQuery.of(context).disableAnimations
/// - Provide instant alternatives for critical actions
/// - Don't rely on animations to convey information
/// - Test with reduced motion settings
///
/// ═══════════════════════════════════════════════════════════════════
