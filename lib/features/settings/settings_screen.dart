import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../core/models/game_theme.dart';
import 'controller/settings_controller.dart';
import 'widgets/setting_tile.dart';
import 'widgets/theme_selector.dart';
import '../../core/services/iap_service.dart';

/// Comprehensive settings screen with persistence
///
/// FEATURES:
/// - Audio settings (master/sfx/music volume, toggles)
/// - Visual settings (theme, effects, animations)
/// - Gameplay settings (hints, timer, difficulty)
/// - About section (version, credits, privacy)
/// - Reset to defaults
///
/// ARCHITECTURE:
/// - Uses Riverpod for state management
/// - SettingsController handles updates with auto-save
/// - Material Design 3 components
/// - Smooth animations and haptic feedback
///
/// SECTIONS:
/// 1. Audio (volumes, toggles, haptics)
/// 2. Visual (theme, particles, animations, brightness)
/// 3. Gameplay (hints, timer, confirmations)
/// 4. About (version info, credits, links)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to defaults',
            onPressed: () => _handleResetSettings(context, controller),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ==================== AUDIO SECTION ====================
          const SettingSection(
            title: 'Audio',
            icon: Icons.volume_up,
            subtitle: 'Sound effects, music, and volume controls',
          ),

          SettingTile.toggle(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Play sound effects during gameplay',
            value: settings.sfxEnabled,
            onChanged: (_) => controller.toggleSfx(),
          ),

          if (settings.sfxEnabled)
            SettingTile.slider(
              icon: Icons.graphic_eq,
              title: 'SFX Volume',
              subtitle: 'Sound effects volume level',
              value: settings.sfxVolume,
              onChanged: controller.updateSfxVolume,
              divisions: 10,
              valueFormatter: (value) => '${(value * 100).round()}%',
            ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.music_note,
            title: 'Music',
            subtitle: 'Play background music',
            value: settings.musicEnabled,
            onChanged: (_) => controller.toggleMusic(),
          ),

          if (settings.musicEnabled)
            SettingTile.slider(
              icon: Icons.music_note,
              title: 'Music Volume',
              subtitle: 'Background music volume level',
              value: settings.musicVolume,
              onChanged: controller.updateMusicVolume,
              divisions: 10,
              valueFormatter: (value) => '${(value * 100).round()}%',
            ),

          const SettingDivider(),

          SettingTile.slider(
            icon: Icons.volume_down,
            title: 'Master Volume',
            subtitle: 'Overall volume control',
            value: settings.masterVolume,
            onChanged: controller.updateMasterVolume,
            divisions: 10,
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Vibration feedback for actions',
            value: settings.hapticsEnabled,
            onChanged: (_) => controller.toggleHaptics(),
          ),

          const SizedBox(height: 16.0),

          // ==================== VISUAL SECTION ====================
          const SettingSection(
            title: 'Visual',
            icon: Icons.palette,
            subtitle: 'Theme, effects, and appearance',
          ),

          SettingTile.navigation(
            icon: Icons.color_lens,
            title: 'Game Theme',
            subtitle: settings.themeType.displayName,
            onTap: () => _showThemeSelector(context, settings.themeType, controller),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.auto_awesome,
            title: 'Particle Effects',
            subtitle: 'Show particle effects during gameplay',
            value: settings.particleEffects,
            onChanged: (_) => controller.toggleParticleEffects(),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.animation,
            title: 'Animations',
            subtitle: 'Enable smooth animations',
            value: settings.animationsEnabled,
            onChanged: (_) => controller.toggleAnimations(),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.accessibility_new,
            title: 'Reduced Motion',
            subtitle: 'Minimize animations for accessibility',
            value: settings.reducedMotion,
            onChanged: (_) => controller.toggleReducedMotion(),
          ),

          const SettingDivider(),

          SettingTile.value(
            icon: Icons.brightness_6,
            title: 'Brightness',
            subtitle: 'App theme brightness',
            value: settings.brightness == Brightness.light ? 'Light' : 'Dark',
            onTap: () => _showBrightnessDialog(context, settings.brightness, controller),
          ),

          const SizedBox(height: 16.0),

          // ==================== GAMEPLAY SECTION ====================
          const SettingSection(
            title: 'Gameplay',
            icon: Icons.sports_esports,
            subtitle: 'Game behavior and assistance',
          ),

          SettingTile.value(
            icon: Icons.lightbulb_outline,
            title: 'Hint Cooldown',
            subtitle: 'Time between hint uses',
            value: '${settings.hintCooldownSeconds}s',
            onTap: () => _showHintCooldownDialog(context, settings.hintCooldownSeconds, controller),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.timer,
            title: 'Show Timer',
            subtitle: 'Display elapsed time during gameplay',
            value: settings.showTimer,
            onChanged: (_) => controller.toggleShowTimer(),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.save,
            title: 'Auto Save',
            subtitle: 'Automatically save game progress',
            value: settings.autoSave,
            onChanged: (_) => controller.toggleAutoSave(),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.undo,
            title: 'Confirm Undo',
            subtitle: 'Require confirmation before undoing',
            value: settings.confirmUndo,
            onChanged: (_) => controller.toggleConfirmUndo(),
          ),

          const SettingDivider(),

          SettingTile.toggle(
            icon: Icons.format_list_numbered,
            title: 'Show Moves Count',
            subtitle: 'Display number of moves taken',
            value: settings.showMovesCount,
            onChanged: (_) => controller.toggleShowMovesCount(),
          ),

          const SizedBox(height: 16.0),

          // ==================== STORE SECTION ====================
          const SettingSection(
            title: 'Store',
            icon: Icons.store,
            subtitle: 'In-app purchases and rewards',
          ),

          SettingTile.navigation(
            icon: Icons.ads_click,
            title: 'Remove Ads',
            subtitle: 'Enjoy an ad-free experience',
            onTap: () => _showStoreDialog(context, ref, 'remove_ads'),
          ),

          const SettingDivider(),

          SettingTile.navigation(
            icon: Icons.monetization_on,
            title: 'Buy Coins',
            subtitle: 'Get more coins for hints',
            onTap: () => _showStoreDialog(context, ref, 'coins_100'),
          ),

          const SizedBox(height: 16.0),

          // ==================== ABOUT SECTION ====================
          const SettingSection(
            title: 'About',
            icon: Icons.info_outline,
            subtitle: 'App information and support',
          ),

          SettingTile.navigation(
            icon: Icons.info,
            title: 'About',
            subtitle: 'Version and app information',
            onTap: () => _showAboutDialog(context),
          ),

          const SettingDivider(),

          SettingTile.navigation(
            icon: Icons.people,
            title: 'Credits',
            subtitle: 'Development team and contributors',
            onTap: () => _showCreditsDialog(context),
          ),

          const SettingDivider(),

          SettingTile.navigation(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => _showPrivacyDialog(context),
          ),

          const SettingDivider(),

          SettingTile.navigation(
            icon: Icons.star_rate,
            title: 'Rate App',
            subtitle: 'Enjoying the game? Leave a review!',
            onTap: () => _handleRateApp(context),
          ),

          const SizedBox(height: 32.0),

          // Back to home button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ),

          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  // ==================== DIALOG HELPERS ====================

  /// Show theme selector bottom sheet
  void _showThemeSelector(
    BuildContext context,
    ThemeType currentTheme,
    SettingsController controller,
  ) {
    showThemeSelectorSheet(
      context: context,
      currentTheme: currentTheme,
      onThemeSelected: controller.updateThemeType,
    );
  }

  /// Show brightness selection dialog
  void _showBrightnessDialog(
    BuildContext context,
    Brightness currentBrightness,
    SettingsController controller,
  ) {
    showPickerDialog<Brightness>(
      context: context,
      title: 'Select Brightness',
      items: Brightness.values,
      currentValue: currentBrightness,
      itemBuilder: (brightness) => ListTile(
        leading: Icon(
          brightness == Brightness.light ? Icons.light_mode : Icons.dark_mode,
        ),
        title: Text(
          brightness == Brightness.light ? 'Light Mode' : 'Dark Mode',
        ),
      ),
    ).then((brightness) {
      if (brightness != null) {
        controller.updateBrightness(brightness);
      }
    });
  }

  /// Show hint cooldown selection dialog
  void _showHintCooldownDialog(
    BuildContext context,
    int currentCooldown,
    SettingsController controller,
  ) {
    final cooldownOptions = [10, 20, 30, 45, 60, 90, 120, 180, 300];

    showPickerDialog<int>(
      context: context,
      title: 'Hint Cooldown',
      items: cooldownOptions,
      currentValue: currentCooldown,
      itemBuilder: (seconds) => ListTile(
        title: Text(_formatCooldownDuration(seconds)),
      ),
    ).then((seconds) {
      if (seconds != null) {
        controller.updateHintCooldown(seconds);
      }
    });
  }

  /// Format cooldown duration for display
  String _formatCooldownDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds == 60) {
      return '1 minute';
    } else if (seconds % 60 == 0) {
      return '${seconds ~/ 60} minutes';
    } else {
      return '${seconds ~/ 60}m ${seconds % 60}s';
    }
  }

  /// Handle reset settings with confirmation
  void _handleResetSettings(
    BuildContext context,
    SettingsController controller,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Reset Settings',
      message: 'Are you sure you want to reset all settings to their default values?',
      confirmText: 'Reset',
      isDestructive: true,
    );

    if (confirmed) {
      await controller.resetToDefaults();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Puzzle Game Suite',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.games, size: 64),
      applicationLegalese: '© 2024 Eryx Labs Ltd',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A collection of color-sorting puzzle games with beautiful themes and challenging levels.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Features four unique game themes: Water Sort, Nuts & Bolts, Ball Sort, and Test Tubes.',
        ),
      ],
    );
  }

  /// Show credits dialog
  void _showCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credits'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCreditSection('Development', [
                'Lead Developer: Eryx Labs Team',
                'UI/UX Design: Material Design 3',
                'Game Engine: Flutter',
              ]),
              const SizedBox(height: 16),
              _buildCreditSection('Special Thanks', [
                'Flutter Team',
                'Riverpod Community',
                'Open Source Contributors',
              ]),
              const SizedBox(height: 16),
              _buildCreditSection('Assets', [
                'Icons: Material Icons',
                'Sounds: Freesound.org',
                'Testing: Beta Testers',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text('• $item'),
            )),
      ],
    );
  }

  /// Show privacy policy dialog
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'This app stores your game progress and settings locally on your device. '
                'No personal data is transmitted to external servers.',
              ),
              SizedBox(height: 16),
              Text(
                'Local Storage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'We use SharedPreferences to store:\n'
                '• Game progress and scores\n'
                '• Settings and preferences\n'
                '• Unlocked levels\n\n'
                'This data remains on your device and can be cleared by uninstalling the app.',
              ),
              SizedBox(height: 16),
              Text(
                'Analytics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'This version does not include any analytics or tracking.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Handle rate app action
  void _handleRateApp(BuildContext context) {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks for your support! Rating feature coming soon.'),
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Implement actual app store rating
    // In production, use url_launcher or in_app_review packages:
    // - iOS: Launch App Store
    // - Android: Launch Play Store
    // - Web: Show feedback form
  }

  void _showStoreDialog(BuildContext context, WidgetRef ref, String productId) {
    final iapService = ref.read(iapServiceProvider);
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: iapService.loadProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load products.'),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
            final products = snapshot.data ?? [];
            final product = products.firstWhere(
              (p) => p.id == productId,
              orElse: () => products.first,
            );
            return AlertDialog(
              title: Text(product.title),
              content: Text(product.description),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    iapService.buyProduct(product);
                    context.pop();
                  },
                  child: Text(product.price),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
