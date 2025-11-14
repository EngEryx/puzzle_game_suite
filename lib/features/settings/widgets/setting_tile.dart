import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable setting row widget with consistent styling
///
/// Supports multiple types of controls:
/// - Toggle switch
/// - Slider
/// - Navigation (chevron)
/// - Custom widget
///
/// DESIGN PRINCIPLES:
/// - Consistent Material Design 3 styling
/// - Accessible (semantic labels, contrast)
/// - Haptic feedback on interaction
/// - Smooth animations
///
/// USAGE:
/// ```dart
/// SettingTile.toggle(
///   icon: Icons.volume_up,
///   title: 'Sound Effects',
///   subtitle: 'Play sound effects',
///   value: sfxEnabled,
///   onChanged: (value) => controller.toggleSfx(),
/// )
/// ```
class SettingTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool enabled;

  const SettingTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.enabled = true,
  });

  /// Create a toggle switch setting
  factory SettingTile.toggle({
    Key? key,
    IconData? icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
    bool enabled = true,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
    );
  }

  /// Create a slider setting
  factory SettingTile.slider({
    Key? key,
    IconData? icon,
    required String title,
    String? subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String Function(double)? valueFormatter,
    Color? iconColor,
    bool enabled = true,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (valueFormatter != null)
            Text(
              valueFormatter(value),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(
            width: 150,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Create a navigation setting (with chevron)
  factory SettingTile.navigation({
    Key? key,
    IconData? icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool enabled = true,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Create a value display setting
  factory SettingTile.value({
    Key? key,
    IconData? icon,
    required String title,
    String? subtitle,
    required String value,
    VoidCallback? onTap,
    Color? iconColor,
    bool enabled = true,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? null : Colors.grey,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? _handleTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              // Icon
              if (icon != null)
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? colorScheme.primary,
                    size: 24.0,
                  ),
                ),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? null : Colors.grey,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: enabled
                              ? theme.textTheme.bodySmall?.color
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Call onTap if provided
    onTap?.call();
  }
}

/// Section header for settings groups
///
/// USAGE:
/// ```dart
/// SettingSection(
///   title: 'Audio',
///   icon: Icons.volume_up,
/// )
/// ```
class SettingSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? subtitle;

  const SettingSection({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Divider for settings sections
class SettingDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const SettingDivider({
    super.key,
    this.indent = 16.0,
    this.endIndent = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: indent,
      endIndent: endIndent,
      height: 1,
    );
  }
}

/// Picker dialog for selecting from a list of options
///
/// USAGE:
/// ```dart
/// await showPickerDialog<ThemeType>(
///   context: context,
///   title: 'Select Theme',
///   items: ThemeType.values,
///   currentValue: currentTheme,
///   itemBuilder: (theme) => ListTile(
///     title: Text(theme.displayName),
///   ),
/// );
/// ```
Future<T?> showPickerDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required T currentValue,
  required Widget Function(T item) itemBuilder,
}) async {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item == currentValue;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop(item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: itemBuilder(item)),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

/// Confirmation dialog for destructive actions
///
/// USAGE:
/// ```dart
/// final confirmed = await showConfirmDialog(
///   context: context,
///   title: 'Reset Settings',
///   message: 'Are you sure you want to reset all settings?',
///   confirmText: 'Reset',
///   isDestructive: true,
/// );
/// ```
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(true);
          },
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? Colors.red : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
