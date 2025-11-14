import 'package:flutter/material.dart';

/// Reusable game button widget with consistent styling.
///
/// DESIGN PATTERN: Component Library
///
/// This widget provides consistent button styling across the app:
/// - Primary actions (main game actions)
/// - Secondary actions (alternative options)
/// - Icon buttons (compact controls)
///
/// WHY CUSTOM BUTTON?
/// 1. Consistency: All buttons look the same
/// 2. Theming: Easy to update all buttons at once
/// 3. Accessibility: Centralized accessibility features
/// 4. Maintainability: Single source of truth for button behavior
///
/// SIMILAR TO:
/// - Material Design components
/// - Bootstrap buttons (.btn-primary, .btn-secondary)
/// - React component libraries (MUI, Ant Design)
///
/// USAGE:
/// ```dart
/// GameButton(
///   text: 'Undo',
///   onPressed: () => controller.undo(),
///   icon: Icons.undo,
///   style: GameButtonStyle.secondary,
/// )
/// ```
enum GameButtonStyle {
  /// Primary action button (emphasized)
  primary,

  /// Secondary action button (de-emphasized)
  secondary,

  /// Icon-only button (compact)
  icon,
}

class GameButton extends StatelessWidget {
  /// Button text (required for primary/secondary styles)
  final String? text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Optional icon to show
  final IconData? icon;

  /// Button style variant
  final GameButtonStyle style;

  /// Whether button is enabled
  /// Note: onPressed == null also disables button
  final bool enabled;

  /// Custom width (null = fit content)
  final double? width;

  /// Custom height (null = use default)
  final double? height;

  const GameButton({
    super.key,
    this.text,
    this.onPressed,
    this.icon,
    this.style = GameButtonStyle.primary,
    this.enabled = true,
    this.width,
    this.height,
  });

  /// Create a primary button
  const GameButton.primary({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.width,
    this.height,
  }) : style = GameButtonStyle.primary;

  /// Create a secondary button
  const GameButton.secondary({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.width,
    this.height,
  }) : style = GameButtonStyle.secondary;

  /// Create an icon button
  const GameButton.icon({
    super.key,
    required IconData this.icon,
    required this.onPressed,
    this.enabled = true,
    this.width,
    this.height,
  })  : text = null,
        style = GameButtonStyle.icon;

  @override
  Widget build(BuildContext context) {
    // Determine if button should be disabled
    final isDisabled = !enabled || onPressed == null;

    // Build different button types based on style
    switch (style) {
      case GameButtonStyle.icon:
        return _buildIconButton(context, isDisabled);
      case GameButtonStyle.primary:
      case GameButtonStyle.secondary:
        return _buildTextButton(context, isDisabled);
    }
  }

  /// Build icon-only button
  Widget _buildIconButton(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);
    final size = height ?? 56.0;

    return SizedBox(
      width: width ?? size,
      height: size,
      child: Material(
        color: isDisabled
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              icon,
              color: isDisabled
                  ? theme.colorScheme.onSurface.withOpacity(0.38)
                  : theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Build text button (primary or secondary)
  Widget _buildTextButton(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);
    final isPrimary = style == GameButtonStyle.primary;

    // Determine colors based on state and style
    final backgroundColor = isDisabled
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
        : isPrimary
            ? theme.colorScheme.primary
            : theme.colorScheme.secondaryContainer;

    final foregroundColor = isDisabled
        ? theme.colorScheme.onSurface.withOpacity(0.38)
        : isPrimary
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSecondaryContainer;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        elevation: isDisabled ? 0 : (isPrimary ? 2 : 0),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: foregroundColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (text != null)
                  Text(
                    text!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
