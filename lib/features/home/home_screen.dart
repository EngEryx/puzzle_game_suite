import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../levels/controller/level_progress_controller.dart';

/// Home screen - Entry point of the game
///
/// This is where players will:
/// - See the game logo/branding
/// - Start a new game
/// - Continue their progress
/// - Access settings
/// - Select themes
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(levelProgressProvider);
    final completedCount = ref.watch(completedLevelsProvider);
    final totalStars = ref.watch(totalStarsProvider);

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
                const SizedBox(height: 32),

                // Progress Summary Card
                progressState.maybeWhen(
                  loaded: (_, __, ___) => _buildProgressCard(
                    completedCount,
                    totalStars,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // Levels Button (Primary CTA)
                ElevatedButton(
                  onPressed: () => context.go('/levels'),
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
                  child: const Text('Levels'),
                ),
                const SizedBox(height: 16),

                // Quick Play Button (Random level)
                OutlinedButton.icon(
                  onPressed: () => context.go('/game'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Quick Play'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Settings Button
                OutlinedButton.icon(
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build progress summary card
  Widget _buildProgressCard(int completedCount, int totalStars) {
    const totalLevels = 200;
    final percentage = (completedCount / totalLevels * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Completed levels
              _buildStatColumn(
                icon: Icons.check_circle,
                value: '$completedCount/$totalLevels',
                label: 'Levels',
              ),

              // Divider
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),

              // Total stars
              _buildStatColumn(
                icon: Icons.star,
                value: totalStars.toString(),
                label: 'Stars',
              ),

              // Divider
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),

              // Percentage
              _buildStatColumn(
                icon: Icons.trending_up,
                value: '$percentage%',
                label: 'Complete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat column
  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.amber,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
