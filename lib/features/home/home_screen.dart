import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home screen - Entry point of the game
///
/// This is where players will:
/// - See the game logo/branding
/// - Start a new game
/// - Continue their progress
/// - Access settings
/// - Select themes
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title
                const Text(
                  'Puzzle Game Suite',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '4-in-1 Collection',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 64),

                // Play Button
                ElevatedButton(
                  onPressed: () => context.go('/game'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Play'),
                ),
                const SizedBox(height: 16),

                // Settings Button
                OutlinedButton(
                  onPressed: () => context.go('/settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
