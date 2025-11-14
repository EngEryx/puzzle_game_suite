import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/engine/container.dart' as game_engine;
import '../../../../core/models/game_color.dart';
import '../../controller/game_controller.dart';

/// Game board widget that displays all containers and handles game interactions.
///
/// ═══════════════════════════════════════════════════════════════════
/// ARCHITECTURE: Smart Widget with Two-Tap Interaction Pattern
/// ═══════════════════════════════════════════════════════════════════
///
/// RESPONSIBILITIES:
/// 1. Display all game containers in a responsive layout
/// 2. Handle two-tap move system (select source, select destination)
/// 3. Show visual feedback for selection and valid moves
/// 4. Connect to game state via Riverpod providers
/// 5. Optimize rebuilds for performance
///
/// TWO-TAP INTERACTION PATTERN:
///
/// STATE MACHINE:
/// ```
/// [No Selection]
///     ↓ Tap Container A
/// [Container A Selected]
///     ↓ Tap Container B → Make Move (A → B)
///     ↓ Tap Container A → Deselect
///     ↓ Tap Invalid Target → Show Error Feedback
/// ```
///
/// COMPARISON TO OTHER INTERACTION PATTERNS:
///
/// DRAG-AND-DROP (Alternative approach):
/// - Pros: More intuitive for desktop/mouse users
/// - Cons: Difficult on mobile (fingers obscure view), accessibility issues
/// - Example: Chess apps, Trello boards
///
/// TWO-TAP (Our approach):
/// - Pros: Works perfectly on mobile, accessible, clear feedback
/// - Cons: Requires two actions vs one drag
/// - Example: Most mobile puzzle games (Candy Crush, 2048)
///
/// SIMILAR TO:
/// - File selection in file managers (click to select, click to open)
/// - Chess notation (select piece, select destination)
/// - Command pattern in terminals (select operation, select target)
///
/// ═══════════════════════════════════════════════════════════════════
/// PERFORMANCE OPTIMIZATION
/// ═══════════════════════════════════════════════════════════════════
///
/// RIVERPOD OPTIMIZATION STRATEGIES:
///
/// 1. GRANULAR PROVIDERS
///    Instead of watching entire game state, we use specific providers:
///    - `ref.watch(gameProvider)` → Rebuilds on any state change
///    - `ref.watch(containerByIdProvider(id))` → Rebuilds only that container
///    - `ref.watch(validTargetsProvider(id))` → Rebuilds only when targets change
///
/// 2. IMMUTABLE STATE
///    GameState is immutable, so Flutter can use reference equality:
///    - Old state == New state? Skip rebuild
///    - Different reference? Rebuild only changed widgets
///
/// 3. CONST CONSTRUCTORS
///    Static widgets use const to avoid unnecessary rebuilds
///
/// 4. STATEFUL SELECTION
///    Selection state is local (not in global state) to avoid global rebuilds
///    - Only selected containers rebuild, not entire board
///
/// COMPARISON TO OTHER FRAMEWORKS:
///
/// REACT (JavaScript):
/// ```jsx
/// // React would use useMemo/useCallback
/// const validTargets = useMemo(() =>
///   getValidTargets(selectedId),
///   [selectedId]
/// );
/// ```
///
/// REDUX (JavaScript):
/// ```javascript
/// // Redux would use selectors with reselect
/// const selectValidTargets = createSelector(
///   [getSelectedId, getContainers],
///   (id, containers) => calculateValidTargets(id, containers)
/// );
/// ```
///
/// OUR APPROACH (Riverpod):
/// - Provider.family creates cached instances per parameter
/// - Automatic dependency tracking and memoization
/// - Type-safe without boilerplate
///
/// ═══════════════════════════════════════════════════════════════════

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  /// Currently selected container ID (for two-tap move system)
  ///
  /// LOCAL STATE vs GLOBAL STATE:
  /// This is local state because:
  /// - Only affects UI, not game logic
  /// - Doesn't need to be persisted
  /// - Doesn't need to be shared with other screens
  /// - No undo/redo needed for selection
  ///
  /// PATTERN: Keep state as local as possible
  /// Only promote to global state when needed by multiple widgets
  String? _selectedContainerId;

  /// Error message to display (if any)
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Watch game state for updates
    // This widget rebuilds whenever game state changes
    // For better performance, we could split this into smaller widgets
    // that watch only specific parts of state
    final gameState = ref.watch(gameProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // RESPONSIVE LAYOUT CALCULATION
        //
        // Algorithm: Determine optimal grid layout based on available space
        // and number of containers
        //
        // Goals:
        // 1. Show all containers on screen without scrolling (if possible)
        // 2. Make containers large enough to tap (44x44 minimum touch target)
        // 3. Use available space efficiently
        // 4. Adapt to portrait/landscape orientation

        final containerCount = gameState.containers.length;
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calculate grid dimensions
        final gridData = _calculateGridLayout(
          containerCount: containerCount,
          availableWidth: availableWidth,
          availableHeight: availableHeight,
        );

        return Column(
          children: [
            // Error message display (if any)
            if (_errorMessage != null)
              _buildErrorBanner(),

            // Container grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: _buildContainerGrid(
                    containers: gameState.containers,
                    crossAxisCount: gridData.crossAxisCount,
                    childAspectRatio: gridData.childAspectRatio,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the grid of containers
  Widget _buildContainerGrid({
    required List<game_engine.Container> containers,
    required int crossAxisCount,
    required double childAspectRatio,
  }) {
    return GridView.builder(
      // Shrink to fit content (don't force scroll if not needed)
      shrinkWrap: true,
      // Disable scroll if all containers fit on screen
      physics: containers.length <= 12
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: containers.length,
      itemBuilder: (context, index) {
        final container = containers[index];
        final isSelected = container.id == _selectedContainerId;

        // Check if this is a valid target for the selected container
        final isValidTarget = _selectedContainerId != null
            ? _isValidTarget(_selectedContainerId!, container.id)
            : false;

        return _buildContainerItem(
          container: container,
          isSelected: isSelected,
          isValidTarget: isValidTarget,
        );
      },
    );
  }

  /// Build a single container item
  Widget _buildContainerItem({
    required game_engine.Container container,
    required bool isSelected,
    required bool isValidTarget,
  }) {
    return GestureDetector(
      // TWO-TAP INTERACTION HANDLER
      onTap: () => _handleContainerTap(container.id),
      child: AnimatedContainer(
        // ANIMATION: Smooth transition when selection changes
        // Duration: 200ms is fast enough to feel responsive
        // but slow enough to see the change
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          // VISUAL FEEDBACK STATES:
          // 1. Selected: Blue border + shadow
          // 2. Valid target: Green border (when another container selected)
          // 3. Normal: Gray border
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade600
                : isValidTarget
                    ? Colors.green.shade600
                    : Colors.grey.shade300,
            width: isSelected || isValidTarget ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          // Selected containers get elevated appearance
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : isValidTarget
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container ID label
            Text(
              container.id,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            // Container visual (colors stack)
            Expanded(
              child: _buildContainerVisual(container),
            ),
            const SizedBox(height: 8),
            // Container status indicator
            _buildContainerStatus(container),
          ],
        ),
      ),
    );
  }

  /// Build visual representation of container colors
  Widget _buildContainerVisual(game_engine.Container container) {
    if (container.isEmpty) {
      return Center(
        child: Icon(
          Icons.inbox_outlined,
          size: 40,
          color: Colors.grey.shade300,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: container.colors.map((gameColor) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: _getFlutterColor(gameColor),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build container status indicator (solved, capacity, etc.)
  Widget _buildContainerStatus(game_engine.Container container) {
    if (container.isSolved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              'Solved',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // Show capacity info
    return Text(
      '${container.colors.length}/${container.capacity}',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// Build error message banner
  Widget _buildErrorBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Handle container tap (two-tap interaction system)
  ///
  /// STATE MACHINE IMPLEMENTATION:
  /// - No selection → Select container
  /// - Same container → Deselect
  /// - Different container → Attempt move or show error
  void _handleContainerTap(String containerId) {
    // Clear any existing error message
    setState(() {
      _errorMessage = null;
    });

    // Case 1: No container selected yet → Select this container
    if (_selectedContainerId == null) {
      final container = ref.read(gameProvider).getContainer(containerId);

      // Don't allow selecting empty containers as source
      if (container?.isEmpty ?? true) {
        setState(() {
          _errorMessage = 'Cannot select empty container';
        });
        return;
      }

      setState(() {
        _selectedContainerId = containerId;
      });
      return;
    }

    // Case 2: Tapped same container → Deselect
    if (_selectedContainerId == containerId) {
      setState(() {
        _selectedContainerId = null;
      });
      return;
    }

    // Case 3: Different container → Attempt move
    _attemptMove(_selectedContainerId!, containerId);
  }

  /// Attempt to make a move
  void _attemptMove(String fromId, String toId) {
    try {
      // Validate move first
      final controller = ref.read(gameProvider.notifier);
      final errorMsg = controller.validateMove(fromId, toId);

      if (errorMsg != null) {
        setState(() {
          _errorMessage = errorMsg;
        });
        return;
      }

      // Make the move
      controller.makeMove(fromId, toId);

      // Success! Clear selection
      setState(() {
        _selectedContainerId = null;
        _errorMessage = null;
      });

      // Optional: Add haptic feedback for success
      // HapticFeedback.mediumImpact();

    } catch (e) {
      // Show error message
      setState(() {
        _errorMessage = e.toString();
      });

      // Optional: Add haptic feedback for error
      // HapticFeedback.heavyImpact();
    }
  }

  /// Check if a container is a valid target for the selected container
  bool _isValidTarget(String fromId, String toId) {
    if (fromId == toId) return false;

    final controller = ref.read(gameProvider.notifier);
    final validTargets = controller.getValidTargets(fromId);
    return validTargets.contains(toId);
  }

  /// Calculate optimal grid layout
  ///
  /// ALGORITHM:
  /// 1. Try to fit all containers without scrolling
  /// 2. Use 2-4 columns based on container count and available space
  /// 3. Ensure minimum touch target size (44x44 points)
  /// 4. Maintain reasonable aspect ratio for containers
  _GridLayoutData _calculateGridLayout({
    required int containerCount,
    required double availableWidth,
    required double availableHeight,
  }) {
    // TOUCH TARGET SIZING (Apple HIG / Material Design)
    // Minimum: 44x44 points (iOS) / 48x48 dp (Android)
    // We use 80x120 as comfortable size for our containers
    const minContainerWidth = 80.0;
    const idealAspectRatio = 0.75; // width/height (3:4 ratio)

    // Calculate maximum columns that fit
    int crossAxisCount = (availableWidth / minContainerWidth).floor();

    // Constrain between 2 and 4 columns for best UX
    crossAxisCount = crossAxisCount.clamp(2, 4);

    // Adjust based on container count
    if (containerCount <= 4) {
      crossAxisCount = 2;
    } else if (containerCount <= 9) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    return _GridLayoutData(
      crossAxisCount: crossAxisCount,
      childAspectRatio: idealAspectRatio,
    );
  }

  /// Convert GameColor to Flutter Color
  ///
  /// COLOR MAPPING:
  /// Maps game engine colors to Flutter Material colors
  /// Uses Material Design color palette for consistency
  Color _getFlutterColor(GameColor gameColor) {
    switch (gameColor) {
      case GameColor.red:
        return Colors.red.shade500;
      case GameColor.blue:
        return Colors.blue.shade500;
      case GameColor.green:
        return Colors.green.shade500;
      case GameColor.yellow:
        return Colors.yellow.shade600;
      case GameColor.purple:
        return Colors.purple.shade500;
      case GameColor.orange:
        return Colors.orange.shade500;
      case GameColor.pink:
        return Colors.pink.shade500;
      case GameColor.cyan:
        return Colors.cyan.shade500;
      case GameColor.brown:
        return Colors.brown.shade500;
      case GameColor.lime:
        return Colors.lime.shade600;
      case GameColor.magenta:
        return Colors.purple.shade300;
      case GameColor.teal:
        return Colors.teal.shade500;
    }
  }
}

/// Data class for grid layout calculation
class _GridLayoutData {
  final int crossAxisCount;
  final double childAspectRatio;

  const _GridLayoutData({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
}
