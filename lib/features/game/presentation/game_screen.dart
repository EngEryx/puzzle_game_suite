import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/game_button.dart';
import '../controller/game_controller.dart';

/// Main game screen where the puzzle gameplay happens.
///
/// ARCHITECTURE: MVVM + Riverpod State Management
///
/// COMPONENTS:
/// - View: GameScreen (this file) - displays UI
/// - ViewModel: GameController - manages state and logic
/// - Model: GameState, Level, Container - pure data
///
/// STATE FLOW:
/// 1. User interacts with UI (tap button)
/// 2. UI calls controller method via ref.read()
/// 3. Controller updates state
/// 4. Riverpod notifies listeners
/// 5. UI rebuilds via ref.watch()
///
/// LIFECYCLE:
/// - initState: Initialize game with tutorial level
/// - build: Render current state
/// - dispose: Cleanup (Riverpod handles this)
///
/// ERROR HANDLING:
/// - Invalid moves: Show snackbar
/// - Game state errors: Display error message
/// - Controller exceptions: Catch and display to user
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  /// Selected container ID for multi-tap move input
  /// Null = no selection
  String? _selectedContainerId;

  @override
  void initState() {
    super.initState();
    // Initialize game on screen load
    // We do this in the next frame to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  /// Initialize game with tutorial level
  void _initializeGame() {
    try {
      // Get the controller to ensure the game is initialized
      // Note: currentLevelProvider already provides tutorial level by default
      // The game provider automatically creates a game from currentLevelProvider
      ref.read(gameProvider.notifier);
    } catch (e) {
      _showError('Failed to initialize game: $e');
    }
  }

  /// Handle container tap for move input
  ///
  /// MOVE INPUT FLOW:
  /// 1. User taps first container (source)
  /// 2. Container is highlighted as selected
  /// 3. User taps second container (target)
  /// 4. Move is executed
  /// 5. Selection is cleared
  void _onContainerTap(String containerId) {
    final state = ref.read(gameProvider);

    // Don't allow moves if game is over
    if (state.isGameOver) {
      _showMessage('Game is over!');
      return;
    }

    // First tap: select source container
    if (_selectedContainerId == null) {
      final container = state.getContainer(containerId);
      if (container == null) return;

      // Can't select empty container as source
      if (container.isEmpty) {
        _showMessage('Container is empty');
        return;
      }

      setState(() {
        _selectedContainerId = containerId;
      });
      return;
    }

    // Second tap: execute move
    final fromId = _selectedContainerId!;
    final toId = containerId;

    // Clear selection
    setState(() {
      _selectedContainerId = null;
    });

    // Don't allow moving to same container
    if (fromId == toId) {
      _showMessage('Select a different container');
      return;
    }

    // Execute move
    _makeMove(fromId, toId);
  }

  /// Execute a move
  void _makeMove(String fromId, String toId) {
    try {
      final controller = ref.read(gameProvider.notifier);
      controller.makeMove(fromId, toId);

      // Check for win/loss after move
      final state = ref.read(gameProvider);
      if (state.isWon) {
        _showWinDialog();
      } else if (state.isLost) {
        _showLossDialog();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Handle undo button
  void _onUndo() {
    try {
      final controller = ref.read(gameProvider.notifier);
      controller.undo();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Handle reset button
  void _onReset() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Level?'),
        content: const Text('This will restart the level from the beginning.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              final controller = ref.read(gameProvider.notifier);
              controller.reset();
              setState(() {
                _selectedContainerId = null;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Handle hint button (placeholder)
  void _onHint() {
    _showMessage('Hint system coming soon!');
  }

  /// Show win dialog
  void _showWinDialog() {
    final state = ref.read(gameProvider);
    final stars = state.currentStars;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Moves: ${state.moveCount}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (stars > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getStarMessage(stars),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/'); // Go to home
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              context.pop(); // Close dialog
              final controller = ref.read(gameProvider.notifier);
              controller.reset();
              setState(() {
                _selectedContainerId = null;
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  /// Show loss dialog
  void _showLossDialog() {
    final state = ref.read(gameProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Out of Moves'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve used all ${state.level.moveLimit} moves.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try again with a better strategy!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go('/'); // Go to home
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              context.pop(); // Close dialog
              final controller = ref.read(gameProvider.notifier);
              controller.reset();
              setState(() {
                _selectedContainerId = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Get message based on star rating
  String _getStarMessage(int stars) {
    switch (stars) {
      case 3:
        return 'Perfect! Outstanding performance!';
      case 2:
        return 'Great job! Can you do better?';
      case 1:
        return 'Good! Try to use fewer moves.';
      default:
        return 'Completed!';
    }
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch game state - rebuilds when state changes
    final state = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.level.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game Header (level info, moves, stars)
              _buildGameHeader(state),

              const SizedBox(height: 16),

              // Game Board (containers grid)
              Expanded(
                child: _buildGameBoard(state),
              ),

              const SizedBox(height: 16),

              // Game Controls (undo, reset, hint)
              _buildGameControls(state),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build game header with level info and stats
  Widget _buildGameHeader(state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Level description
          if (state.level.description != null)
            Text(
              state.level.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Moves counter
              _buildStatCard(
                icon: Icons.swap_horiz,
                label: 'Moves',
                value: state.moveCount.toString(),
                subtitle: state.level.moveLimit != null
                    ? '/ ${state.level.moveLimit}'
                    : null,
              ),

              // Stars
              if (state.level.starThresholds != null)
                _buildStatCard(
                  icon: Icons.star,
                  label: 'Stars',
                  value: state.isWon ? state.currentStars.toString() : '-',
                  subtitle: '/ 3',
                ),

              // Difficulty
              _buildStatCard(
                icon: Icons.trending_up,
                label: 'Difficulty',
                value: state.level.difficulty.displayName,
                subtitle: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build game board with containers
  ///
  /// TODO: This is a placeholder until GameBoard widget is created
  /// For now, we'll show a simple grid of container placeholders
  Widget _buildGameBoard(state) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: state.containers.map((container) {
              final isSelected = _selectedContainerId == container.id;
              return _buildContainerPlaceholder(container, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Build container placeholder
  ///
  /// TODO: Replace with actual ContainerWidget when available
  Widget _buildContainerPlaceholder(container, bool isSelected) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onContainerTap(container.id),
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Colors (bottom to top)
            ...container.colors.map((color) {
              return Container(
                width: double.infinity,
                height: 120 / container.capacity,
                decoration: BoxDecoration(
                  color: _getColorForGameColor(color),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              );
            }),
            // Empty space indicator
            if (container.colors.length < container.capacity)
              Expanded(
                child: Center(
                  child: Text(
                    container.id,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Map GameColor to Flutter Color
  ///
  /// TODO: Move this to a theme/color utility file
  Color _getColorForGameColor(gameColor) {
    switch (gameColor.toString().split('.').last) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      case 'brown':
        return Colors.brown;
      case 'lime':
        return Colors.lime;
      case 'magenta':
        return Colors.pink.shade300;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Build game controls
  Widget _buildGameControls(state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          GameButton.icon(
            icon: Icons.undo,
            onPressed: state.canUndo ? _onUndo : null,
            enabled: state.canUndo,
          ),

          // Reset button
          GameButton.secondary(
            text: 'Reset',
            icon: Icons.refresh,
            onPressed: _onReset,
          ),

          // Hint button (placeholder)
          GameButton.icon(
            icon: Icons.lightbulb_outline,
            onPressed: _onHint,
          ),
        ],
      ),
    );
  }
}
