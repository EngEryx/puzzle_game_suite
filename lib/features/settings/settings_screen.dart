import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen
///
/// Eventually will contain:
/// - Sound on/off
/// - Music on/off
/// - Haptic feedback toggle
/// - Theme selector
/// - Language selection
/// - About/credits
/// - Privacy policy
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.volume_up),
            title: Text('Sound'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Music'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.vibration),
            title: Text('Haptic Feedback'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme Selection'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Puzzle Game Suite',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Eryx Labs Ltd',
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}
