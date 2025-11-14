import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/game_theme.dart';
import '../../../core/models/game_color.dart';

/// Visual theme picker widget
///
/// Displays all available game themes in a grid with preview cards.
/// Shows a visual preview of each theme's appearance.
///
/// DESIGN:
/// - Grid layout for multiple themes
/// - Visual preview with color samples
/// - Current theme indicator
/// - Smooth selection animation
/// - Haptic feedback on selection
///
/// USAGE:
/// ```dart
/// ThemeSelector(
///   currentTheme: ThemeType.water,
///   onThemeSelected: (theme) {
///     controller.updateThemeType(theme);
///   },
/// )
/// ```
class ThemeSelector extends StatelessWidget {
  final ThemeType currentTheme;
  final ValueChanged<ThemeType> onThemeSelected;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Game Theme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Choose your favorite visual style',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.85,
            ),
            itemCount: ThemeType.values.length,
            itemBuilder: (context, index) {
              final theme = ThemeType.values[index];
              final isSelected = theme == currentTheme;

              return ThemeCard(
                theme: theme,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onThemeSelected(theme);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual theme card with preview
class ThemeCard extends StatefulWidget {
  final ThemeType theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary
                  : Colors.grey.shade300,
              width: widget.isSelected ? 3.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: widget.isSelected ? 12.0 : 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme preview area
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14.0),
                  ),
                  child: _ThemePreview(theme: widget.theme),
                ),
              ),

              // Theme info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.theme.icon,
                          size: 20,
                          color: widget.isSelected
                              ? colorScheme.primary
                              : Colors.grey[700],
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            widget.theme.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: widget.isSelected
                                  ? colorScheme.primary
                                  : Colors.grey[900],
                            ),
                          ),
                        ),
                        if (widget.isSelected)
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      widget.theme.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual preview of a theme
///
/// Shows sample containers with colors to give a feel for the theme
class _ThemePreview extends StatelessWidget {
  final ThemeType theme;

  const _ThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    // Sample colors to preview (first 4 game colors)
    final sampleColors = [
      GameColor.red,
      GameColor.blue,
      GameColor.green,
      GameColor.yellow,
    ];

    return Container(
      color: _getThemeBackgroundColor(theme),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: sampleColors.map((gameColor) {
          return _MiniContainer(
            theme: theme,
            gameColor: gameColor,
          );
        }).toList(),
      ),
    );
  }

  Color _getThemeBackgroundColor(ThemeType theme) {
    return switch (theme) {
      ThemeType.water => const Color(0xFFE3F2FD), // Light blue
      ThemeType.nutsBolts => const Color(0xFFECEFF1), // Light grey
      ThemeType.balls => const Color(0xFFFFF8E1), // Light yellow
      ThemeType.testTubes => const Color(0xFFF1F8E9), // Light green
    };
  }
}

/// Mini container preview showing a single color
class _MiniContainer extends StatelessWidget {
  final ThemeType theme;
  final GameColor gameColor;

  const _MiniContainer({
    required this.theme,
    required this.gameColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getDisplayColor(gameColor, theme);

    return Container(
      width: 20,
      height: 60,
      decoration: BoxDecoration(
        color: theme == ThemeType.water
            ? Colors.grey[200]
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDisplayColor(GameColor gameColor, ThemeType theme) {
    // Get base color from GameColor enum
    final baseColor = _getBaseColor(gameColor);

    // Apply theme-specific modifications
    return switch (theme) {
      ThemeType.water => baseColor.withOpacity(0.7), // Translucent
      ThemeType.nutsBolts => Color.lerp(
          baseColor,
          Colors.grey[700]!,
          0.2,
        )!, // Metallic
      ThemeType.balls => baseColor, // Solid bright
      ThemeType.testTubes => baseColor.withOpacity(0.85), // Semi-translucent
    };
  }

  /// Get Flutter Color from GameColor enum
  Color _getBaseColor(GameColor gameColor) {
    return switch (gameColor) {
      GameColor.red => Colors.red,
      GameColor.blue => Colors.blue,
      GameColor.green => Colors.green,
      GameColor.yellow => Colors.yellow,
      GameColor.purple => Colors.purple,
      GameColor.orange => Colors.orange,
      GameColor.pink => Colors.pink,
      GameColor.cyan => Colors.cyan,
      GameColor.brown => Colors.brown,
      GameColor.lime => Colors.lime,
      GameColor.magenta => const Color(0xFFFF00FF),
      GameColor.teal => Colors.teal,
    };
  }
}

/// Bottom sheet theme selector
///
/// Shows theme selector in a bottom sheet modal.
/// Useful for compact settings screens.
///
/// USAGE:
/// ```dart
/// showThemeSelectorSheet(
///   context: context,
///   currentTheme: ThemeType.water,
///   onThemeSelected: (theme) {
///     controller.updateThemeType(theme);
///   },
/// );
/// ```
Future<ThemeType?> showThemeSelectorSheet({
  required BuildContext context,
  required ThemeType currentTheme,
  required ValueChanged<ThemeType> onThemeSelected,
}) async {
  return showModalBottomSheet<ThemeType>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),

            // Theme selector
            ThemeSelector(
              currentTheme: currentTheme,
              onThemeSelected: (theme) {
                onThemeSelected(theme);
                Navigator.of(context).pop(theme);
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ),
  );
}
