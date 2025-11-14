import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/game_color.dart';
import '../../controller/game_controller.dart';
import 'pour_animation.dart';
import 'pour_animator.dart';

/// Example integration of the pour animation system.
///
/// This file demonstrates how to use the animation components
/// in a real game screen.
///
/// USAGE:
/// - Copy patterns from this example into your game screen
/// - Adapt to your specific UI layout
/// - Customize animation parameters as needed

/// Example game screen with animation support
class AnimatedGameScreenExample extends ConsumerStatefulWidget {
  const AnimatedGameScreenExample({Key? key}) : super(key: key);

  @override
  ConsumerState<AnimatedGameScreenExample> createState() =>
      _AnimatedGameScreenExampleState();
}

class _AnimatedGameScreenExampleState
    extends ConsumerState<AnimatedGameScreenExample>
    with SingleTickerProviderStateMixin {
  // Animation controller for managing pour animations
  late PourAnimator _animator;

  // Currently selected container (for two-tap move pattern)
  String? _selectedContainerId;

  @override
  void initState() {
    super.initState();

    // Initialize animator with vsync from mixin
    _animator = PourAnimator(
      vsync: this,
      animationDuration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Listen to animation updates to rebuild UI
    _animator.addListener(_onAnimationUpdate);
  }

  @override
  void dispose() {
    // IMPORTANT: Always dispose animator to prevent leaks
    _animator.removeListener(_onAnimationUpdate);
    _animator.dispose();
    super.dispose();
  }

  /// Called when animation state changes
  void _onAnimationUpdate() {
    setState(() {
      // Rebuild to show animation progress
    });
  }

  /// Handle container tap - implements two-tap move pattern
  ///
  /// Pattern:
  /// 1. First tap: Select source container
  /// 2. Second tap: Animate move to target container
  void _onContainerTap(String containerId) {
    final controller = ref.read(gameProvider.notifier);

    // Don't allow interaction during animation
    if (controller.isAnimating) {
      return;
    }

    if (_selectedContainerId == null) {
      // First tap - select source container
      setState(() {
        _selectedContainerId = containerId;
      });
    } else if (_selectedContainerId == containerId) {
      // Tap same container - deselect
      setState(() {
        _selectedContainerId = null;
      });
    } else {
      // Second tap - perform animated move
      _performAnimatedMove(_selectedContainerId!, containerId);
    }
  }

  /// Perform animated move between containers
  Future<void> _performAnimatedMove(String fromId, String toId) async {
    final controller = ref.read(gameProvider.notifier);

    try {
      // Start animation through controller
      await controller.animateMove(
        fromId: fromId,
        toId: toId,
        queueIfAnimating: true,
        onAnimationComplete: _onMoveComplete,
      );

      // Clear selection after move starts
      setState(() {
        _selectedContainerId = null;
      });
    } catch (e) {
      // Handle invalid move
      _showError('Invalid move: $e');
      setState(() {
        _selectedContainerId = null;
      });
    }
  }

  /// Called when animation completes
  void _onMoveComplete() {
    // Check win condition
    final state = ref.read(gameProvider);
    if (state.isWon) {
      _showVictory();
    } else if (state.isLost) {
      _showDefeat();
    }

    // Could also:
    // - Play sound effect
    // - Trigger haptic feedback
    // - Update statistics
    // - Save game state
  }

  /// Show error message to user
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show victory dialog
  void _showVictory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Victory!'),
        content: Text('Completed in ${ref.read(gameProvider).moveCount} moves'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).reset();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  /// Show defeat dialog
  void _showDefeat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Out of Moves'),
        content: const Text('Try again?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).reset();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch game state
    final gameState = ref.watch(gameProvider);
    final controller = ref.watch(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Puzzle Game'),
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: gameState.canUndo && !controller.isAnimating
                ? () => controller.undo()
                : null,
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: !controller.isAnimating
                ? () => controller.reset()
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game info
          _buildGameInfo(gameState, controller),

          // Container grid
          Expanded(
            child: _buildContainerGrid(gameState),
          ),

          // Animation debug info (development only)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            _buildDebugInfo(),
        ],
      ),
    );
  }

  /// Build game information display
  Widget _buildGameInfo(GameState state, GameController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            label: 'Moves',
            value: '${state.moveCount}',
            icon: Icons.swap_horiz,
          ),
          if (state.level.moveLimit != null)
            _InfoChip(
              label: 'Limit',
              value: '${state.level.moveLimit}',
              icon: Icons.flag,
            ),
          _InfoChip(
            label: 'Stars',
            value: '${state.currentStars}',
            icon: Icons.star,
            color: Colors.amber,
          ),
          if (controller.isAnimating)
            const _InfoChip(
              label: 'Status',
              value: 'Animating',
              icon: Icons.animation,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  /// Build grid of containers
  Widget _buildContainerGrid(GameState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.5,
      ),
      itemCount: state.containers.length,
      itemBuilder: (context, index) {
        final container = state.containers[index];
        final isSelected = _selectedContainerId == container.id;

        // Get active animations for this container
        final containerAnimations = _animator
            .getAnimationsForContainer(container.id);

        return GestureDetector(
          onTap: () => _onContainerTap(container.id),
          child: _ContainerDisplay(
            container: container,
            isSelected: isSelected,
            animations: containerAnimations,
          ),
        );
      },
    );
  }

  /// Build debug information panel
  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Debug Info:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _animator.debugInfo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Info chip widget for displaying game statistics
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.grey[700], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Container display widget (simplified - use your actual ContainerWidget)
class _ContainerDisplay extends StatelessWidget {
  final dynamic container; // Use your Container type
  final bool isSelected;
  final List<PourAnimation> animations;

  const _ContainerDisplay({
    required this.container,
    required this.isSelected,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.grey,
          width: isSelected ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Your actual ContainerWidget here
          Center(
            child: Text('Container ${container.id}'),
          ),

          // Animation indicator
          if (animations.isNotEmpty)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.animation,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ADVANCED EXAMPLE: Custom Animation Speed Based on Game Mode
// ═══════════════════════════════════════════════════════════════════

/// Example with configurable animation speed
class ConfigurableAnimationExample extends ConsumerStatefulWidget {
  final GameMode mode;

  const ConfigurableAnimationExample({
    Key? key,
    required this.mode,
  }) : super(key: key);

  @override
  ConsumerState<ConfigurableAnimationExample> createState() =>
      _ConfigurableAnimationExampleState();
}

class _ConfigurableAnimationExampleState
    extends ConsumerState<ConfigurableAnimationExample>
    with SingleTickerProviderStateMixin {
  late PourAnimator _animator;

  @override
  void initState() {
    super.initState();
    _animator = PourAnimator(
      vsync: this,
      animationDuration: _getDurationForMode(widget.mode),
    );
  }

  @override
  void didUpdateWidget(ConfigurableAnimationExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) {
      // Recreate animator with new duration
      _animator.dispose();
      _animator = PourAnimator(
        vsync: this,
        animationDuration: _getDurationForMode(widget.mode),
      );
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  Duration _getDurationForMode(GameMode mode) {
    switch (mode) {
      case GameMode.speedRun:
        return const Duration(milliseconds: 300); // Fast
      case GameMode.normal:
        return const Duration(milliseconds: 500); // Balanced
      case GameMode.zen:
        return const Duration(milliseconds: 700); // Slow and relaxing
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implementation similar to main example
    return const Placeholder();
  }
}

enum GameMode {
  speedRun,
  normal,
  zen,
}
