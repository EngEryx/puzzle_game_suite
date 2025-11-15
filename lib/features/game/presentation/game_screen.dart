import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_animations/simple_animations.dart';
import '../controller/game_controller.dart';
import '../../levels/controller/level_progress_controller.dart';
import '../../../core/services/ad_service.dart';
import 'animations/pour_animator.dart';
import 'widgets/animated_game_board.dart';
import 'widgets/animated_game_dialog.dart';
import 'widgets/animated_star_rating.dart';

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
  final String? levelId;

  const GameScreen({super.key, this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  /// Selected container ID for multi-tap move input
  /// Null = no selection
  String? _selectedContainerId;

  /// Animation coordinator for pour animations
  late PourAnimator _animator;

  /// Flag to track if we've shown the game over dialog
  bool _hasShownGameOverDialog = false;

  /// Track previous game over state to detect changes
  bool _previousGameOverState = false;

  @override
  void initState() {
    super.initState();

    // Initialize pour animator
    _animator = PourAnimator(
      vsync: this,
      animationDuration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Initialize game on screen load
    // We do this in the next frame to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    // Dispose animator to prevent memory leaks
    _animator.dispose();
    super.dispose();
  }

  /// Initialize game with specified level or tutorial level
  void _initializeGame() {
    try {
      final controller = ref.read(gameProvider.notifier);

      // If levelId is provided, load that specific level
      if (widget.levelId != null) {
        final level = ref.read(levelByIdProvider(widget.levelId!));
        if (level != null) {
          controller.loadLevel(level);
        } else {
          _showError('Level not found: ${widget.levelId}');
        }
      }
      // Otherwise, use the default level (tutorial)
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

  /// Execute a move with smooth animations and spring physics
  void _makeMove(String fromId, String toId) async {
    try {
      final controller = ref.read(gameProvider.notifier);

      // STEP 1: Immediate state update (ensures game logic works)
      controller.makeMove(fromId, toId);

      // STEP 2: Visual feedback with smooth spring animation
      // Add subtle haptic feedback for premium feel
      HapticFeedback.selectionClick();

      // Animate a quick scale pulse on both containers for visual feedback
      // This gives instant responsiveness while state updates
      await Future.delayed(const Duration(milliseconds: 50));

      // STEP 3: Check for win/loss after animation completes
      final updatedState = ref.read(gameProvider);
      if (updatedState.isWon) {
        // Celebrate win with delay for dramatic effect
        await Future.delayed(const Duration(milliseconds: 300));
        _showWinDialog();
      } else if (updatedState.isLost) {
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
                _hasShownGameOverDialog = false; // Reset flag
                _previousGameOverState = false; // Reset tracking
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Handle hint button
  void _onHint() {
    final gameState = ref.read(gameProvider);

    // Don't allow hints if game is over
    if (gameState.isGameOver) {
      _showMessage('Game is already over!');
      return;
    }

    // Show dialog to ask user to watch an ad for a hint
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get a Hint?'),
        content: const Text('Watch a short video to get a hint.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No Thanks'),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              ref.read(adServiceProvider).showRewardedAd(
                onRewarded: () {
                  // Find first valid move as a simple hint
                  for (final from in gameState.containers) {
                    if (from.isEmpty) continue;

                    for (final to in gameState.containers) {
                      if (from.id == to.id) continue;

                      // Check if this is a valid move
                      if (to.isEmpty || (!to.isFull && to.topColor == from.topColor)) {
                        // Show hint
                        _showMessage('Try moving from ${from.id} to ${to.id}');

                        // Highlight the source container
                        setState(() {
                          _selectedContainerId = from.id;
                        });

                        // Clear selection after 2 seconds
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _selectedContainerId = null;
                            });
                          }
                        });
                        return;
                      }
                    }
                  }
                  _showMessage('No valid moves available');
                },
              );
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  /// Show win dialog
  void _showWinDialog() {
    final state = ref.read(gameProvider);
    final stars = state.currentStars;

    // Save progress
    ref.read(levelProgressProvider.notifier).completeLevel(
      levelId: state.level.id,
      stars: stars,
      moves: state.moveCount,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button from closing dialog
        child: AnimatedGameDialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade700,
                  Colors.blue.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Trophy icon
                PlayAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: 1.1), // Scale up slightly
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Level Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Star rating
                AnimatedStarRating(stars: stars),
                const SizedBox(height: 20),

                // Moves count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Moves: ${state.moveCount}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (stars > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    _getStarMessage(stars),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                // Game-like buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Home button
                    _buildDialogButton(
                      icon: Icons.home,
                      label: 'Home',
                      onPressed: () {
                        ref.read(adServiceProvider).showInterstitialAd();
                        context.pop();
                        context.go('/');
                      },
                      color: Colors.grey.shade700,
                    ),

                    // Retry button
                    _buildDialogButton(
                      icon: Icons.refresh,
                      label: 'Retry',
                      onPressed: () {
                        context.pop();
                        final controller = ref.read(gameProvider.notifier);
                        controller.reset();
                        setState(() {
                          _selectedContainerId = null;
                          _hasShownGameOverDialog = false;
                          _previousGameOverState = false;
                        });
                      },
                      color: Colors.orange.shade700,
                    ),

                    // Next level button
                    _buildDialogButton(
                      icon: Icons.arrow_forward,
                      label: 'Next',
                      onPressed: () {
                        ref.read(adServiceProvider).showInterstitialAd();
                        context.pop();
                        context.go('/levels');
                      },
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show loss dialog
  void _showLossDialog() {
    final state = ref.read(gameProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button from closing dialog
        child: AnimatedGameDialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade700,
                  Colors.orange.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon
                PlayAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: 1.1), // Scale up slightly
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.timer_off,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Out of Moves!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  'You\'ve used all ${state.level.moveLimit} moves.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try again with a better strategy!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Game-like buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Home button
                    _buildDialogButton(
                      icon: Icons.home,
                      label: 'Home',
                      onPressed: () {
                        context.pop();
                        context.go('/');
                      },
                      color: Colors.grey.shade700,
                    ),

                    // Try again button
                    _buildDialogButton(
                      icon: Icons.refresh,
                      label: 'Retry',
                      onPressed: () {
                        context.pop();
                        final controller = ref.read(gameProvider.notifier);
                        controller.reset();
                        setState(() {
                          _selectedContainerId = null;
                          _hasShownGameOverDialog = false;
                          _previousGameOverState = false;
                        });
                      },
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

    // Auto-show game over dialog when game state CHANGES to won/lost
    // Only show if: game just became "game over" AND we have made at least 1 move
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownGameOverDialog &&
          state.isGameOver &&
          !_previousGameOverState &&
          state.moveCount > 0) {
        _hasShownGameOverDialog = true;
        if (state.isWon) {
          _showWinDialog();
        } else if (state.isLost) {
          _showLossDialog();
        }
      }
      _previousGameOverState = state.isGameOver;
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Stack(
            children: <Widget>[
              // Main game area
              Column(
                children: <Widget>[
                  // Compact top bar
                  _buildCompactTopBar(state),

                  // Game Board - takes most space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildGameBoard(state),
                    ),
                  ),

                  // Compact bottom controls
                  _buildCompactControls(state),
                ],
              ),

              // Floating stats button (top right)
              Positioned(
                top: 8,
                right: 8,
                child: _buildStatsButton(state),
              ),

              // Floating back button (top left)
              Positioned(
                top: 8,
                left: 8,
                child: _buildBackButton(),
              ),
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
  Widget _buildGameBoard(state) {
    return AnimatedGameBoard(
      selectedContainerId: _selectedContainerId,
      onContainerTap: _onContainerTap,
      animator: _animator,
    );
  }

  /// Build compact top bar with just level name
  Widget _buildCompactTopBar(state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          state.level.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Build floating back button
  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => context.go('/'),
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  /// Build floating stats button with move count
  Widget _buildStatsButton(state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showStatsModal(state),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${state.moveCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build compact bottom controls - circular icon buttons
  Widget _buildCompactControls(state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Undo button
          _buildCircularButton(
            icon: Icons.undo,
            onPressed: state.canUndo ? _onUndo : null,
            enabled: state.canUndo,
          ),

          // Hint button
          _buildCircularButton(
            icon: Icons.lightbulb_outline,
            onPressed: _onHint,
            enabled: true,
          ),

          // Reset button
          _buildCircularButton(
            icon: Icons.refresh,
            onPressed: _onReset,
            enabled: true,
          ),
        ],
      ),
    );
  }

  /// Build circular button for game controls
  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    // Different gradient colors based on button type
    List<Color> gradientColors;
    Color shadowColor;

    if (icon == Icons.undo) {
      gradientColors = enabled
          ? [Colors.amber.shade400, Colors.orange.shade600]
          : [Colors.grey.shade300, Colors.grey.shade400];
      shadowColor = Colors.amber;
    } else if (icon == Icons.lightbulb_outline) {
      gradientColors = enabled
          ? [Colors.yellow.shade400, Colors.amber.shade600]
          : [Colors.grey.shade300, Colors.grey.shade400];
      shadowColor = Colors.yellow;
    } else {
      gradientColors = enabled
          ? [Colors.blue.shade400, Colors.indigo.shade600]
          : [Colors.grey.shade300, Colors.grey.shade400];
      shadowColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        boxShadow: enabled ? [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// Show stats modal when info button is tapped
  void _showStatsModal(state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Level Info',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildStatItem(
                  icon: Icons.swap_horiz,
                  label: 'Moves',
                  value: '${state.moveCount}${state.level.moveLimit != null ? "/${state.level.moveLimit}" : ""}',
                ),
                _buildStatItem(
                  icon: Icons.star,
                  label: 'Stars',
                  value: state.isWon ? '${state.currentStars}/3' : '-/3',
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Difficulty',
                  value: state.level.difficulty.displayName,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item for modal
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Build game controls (legacy - keeping for compatibility)
  Widget _buildGameControls(state) {
    return _buildCompactControls(state);
  }

  /// Build game-like dialog button
  Widget _buildDialogButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
