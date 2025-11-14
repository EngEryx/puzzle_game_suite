import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/level.dart';
import '../controller/level_progress_controller.dart';
import 'widgets/level_card.dart';

/// Level selection screen
///
/// FEATURES:
/// 1. Grid view of 200 levels
/// 2. Scrollable with smooth performance
/// 3. Filter by difficulty
/// 4. Show overall progress
/// 5. Locked/unlocked states
/// 6. Tap to start level
///
/// PERFORMANCE OPTIMIZATIONS:
/// - GridView.builder for lazy loading
/// - Cached network images (if level thumbnails added)
/// - Riverpod provider caching
/// - Minimal rebuilds with family providers
///
/// UX FEATURES:
/// - Smooth scrolling
/// - Visual feedback
/// - Progress indicators
/// - Difficulty filters
/// - Search (future)
class LevelSelectorScreen extends ConsumerStatefulWidget {
  const LevelSelectorScreen({super.key});

  @override
  ConsumerState<LevelSelectorScreen> createState() =>
      _LevelSelectorScreenState();
}

class _LevelSelectorScreenState extends ConsumerState<LevelSelectorScreen>
    with SingleTickerProviderStateMixin {
  // Filter state
  Difficulty? _selectedDifficulty;

  // Tab controller for difficulty tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedDifficulty = null; // All
          break;
        case 1:
          _selectedDifficulty = Difficulty.easy;
          break;
        case 2:
          _selectedDifficulty = Difficulty.medium;
          break;
        case 3:
          _selectedDifficulty = Difficulty.hard;
          break;
        case 4:
          _selectedDifficulty = Difficulty.expert;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLevels = ref.watch(allLevelsProvider);
    final progressState = ref.watch(levelProgressProvider);

    // Filter levels by selected difficulty
    final filteredLevels = _selectedDifficulty == null
        ? allLevels
        : allLevels.where((l) => l.difficulty == _selectedDifficulty).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, progressState),

              // Difficulty filter tabs
              _buildDifficultyTabs(),

              // Level grid
              Expanded(
                child: _buildLevelGrid(filteredLevels),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with progress and back button
  Widget _buildHeader(BuildContext context, ProgressState progressState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),

              const SizedBox(width: 8),

              // Title
              const Expanded(
                child: Text(
                  'Select Level',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Settings button (future)
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress summary
          progressState.when(
            loading: () => const CircularProgressIndicator(color: Colors.white),
            loaded: (_, totalStars, completedCount) => _buildProgressSummary(
              completedCount,
              totalStars,
            ),
            error: (message) => Text(
              'Error: $message',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build progress summary card
  Widget _buildProgressSummary(int completedCount, int totalStars) {
    const totalLevels = 200;
    final percentage = (completedCount / totalLevels * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Completed levels
          _buildStatItem(
            icon: Icons.check_circle,
            value: '$completedCount/$totalLevels',
            label: 'Completed',
          ),

          // Divider
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),

          // Total stars
          _buildStatItem(
            icon: Icons.star,
            value: totalStars.toString(),
            label: 'Stars',
          ),

          // Divider
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),

          // Percentage
          _buildStatItem(
            icon: Icons.trending_up,
            value: '$percentage%',
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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

  /// Build difficulty filter tabs
  Widget _buildDifficultyTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Easy'),
          Tab(text: 'Medium'),
          Tab(text: 'Hard'),
          Tab(text: 'Expert'),
        ],
      ),
    );
  }

  /// Build level grid
  Widget _buildLevelGrid(List<Level> levels) {
    if (levels.isEmpty) {
      return const Center(
        child: Text(
          'No levels found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Scrollbar(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 cards per row
          childAspectRatio: 0.85, // Slightly taller than wide
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];

          return AnimatedLevelCard(
            key: ValueKey(level.id),
            level: level,
            index: index,
            onTap: () => _onLevelTap(level),
          );
        },
      ),
    );
  }

  /// Handle level card tap
  void _onLevelTap(Level level) {
    // Check if level is unlocked
    final isUnlocked = ref.read(levelUnlockedProvider(level.id));

    if (!isUnlocked) {
      _showLockedDialog(level);
      return;
    }

    // Navigate to game screen with level ID
    context.go('/game/${level.id}');
  }

  /// Show dialog when trying to play locked level
  void _showLockedDialog(Level level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Level Locked'),
        content: Text(
          'Complete previous levels to unlock Level ${level.id.split('_').last}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Responsive level grid
///
/// Adjusts columns based on screen width:
/// - Small screens (phones): 3 columns
/// - Medium screens (tablets): 5 columns
/// - Large screens (desktop): 8 columns
class ResponsiveLevelGrid extends StatelessWidget {
  final List<Level> levels;
  final Function(Level) onLevelTap;

  const ResponsiveLevelGrid({
    super.key,
    required this.levels,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine columns based on width
    int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 3; // Phone
    } else if (screenWidth < 1200) {
      crossAxisCount = 5; // Tablet
    } else {
      crossAxisCount = 8; // Desktop
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return AnimatedLevelCard(
          key: ValueKey(level.id),
          level: level,
          index: index,
          onTap: () => onLevelTap(level),
        );
      },
    );
  }
}

/// Level selector with search functionality
///
/// FUTURE ENHANCEMENT: Add search bar to filter levels by number or name
class LevelSelectorWithSearch extends ConsumerStatefulWidget {
  const LevelSelectorWithSearch({super.key});

  @override
  ConsumerState<LevelSelectorWithSearch> createState() =>
      _LevelSelectorWithSearchState();
}

class _LevelSelectorWithSearchState
    extends ConsumerState<LevelSelectorWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLevels = ref.watch(allLevelsProvider);

    // Filter levels by search query
    final filteredLevels = _searchQuery.isEmpty
        ? allLevels
        : allLevels.where((level) {
            final levelNum = level.id.split('_').last;
            return levelNum.contains(_searchQuery) ||
                level.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title and back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'Select Level',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search levels...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: filteredLevels.isEmpty
                    ? const Center(
                        child: Text(
                          'No levels found',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ResponsiveLevelGrid(
                        levels: filteredLevels,
                        onLevelTap: (level) => context.go('/game/${level.id}'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
