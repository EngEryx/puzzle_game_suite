import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/achievement.dart';
import '../controller/achievement_controller.dart';
import '../widgets/achievement_card.dart';

/// Achievements screen
///
/// FEATURES:
/// 1. Display all achievements (locked + unlocked)
/// 2. Filter by category/type
/// 3. Search functionality
/// 4. Progress statistics
/// 5. Sort options
///
/// UX DESIGN:
/// - Tab-based filtering (All, Level, Star, etc.)
/// - Search bar for finding specific achievements
/// - Stats header showing overall progress
/// - Visual distinction for locked/unlocked
/// - Hidden achievements show as "???"
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  AchievementType? _selectedType;
  String _searchQuery = '';
  bool _showOnlyUnlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementType.values.length + 1, // +1 for "All"
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            _selectedType = null;
          } else {
            _selectedType = AchievementType.values[_tabController.index - 1];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementControllerProvider);
    final stats = ref.watch(achievementStatsProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final filteredAchievements = _filterAchievements(
      state.allAchievements,
      state.progress,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(
              _showOnlyUnlocked ? Icons.lock_open : Icons.lock_outline,
            ),
            tooltip: _showOnlyUnlocked ? 'Show All' : 'Show Unlocked Only',
            onPressed: () {
              setState(() {
                _showOnlyUnlocked = !_showOnlyUnlocked;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Column(
            children: [
              // Stats card
              _buildStatsCard(stats),
              const SizedBox(height: 8),

              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 8),

              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'All'),
                  ...AchievementType.values.map((type) {
                    return Tab(text: _formatTypeName(type));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementList(filteredAchievements, state.progress),
          ...AchievementType.values.map((type) {
            final typeAchievements = filteredAchievements
                .where((a) => a.type == type)
                .toList();
            return _buildAchievementList(typeAchievements, state.progress);
          }),
        ],
      ),
    );
  }

  /// Build stats card
  Widget _buildStatsCard(AchievementStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade700,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Unlocked count
          Expanded(
            child: _buildStatColumn(
              icon: Icons.emoji_events,
              value: '${stats.unlocked}/${stats.total}',
              label: 'Unlocked',
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),

          // Points
          Expanded(
            child: _buildStatColumn(
              icon: Icons.star,
              value: '${stats.points}',
              label: 'Points',
            ),
          ),

          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),

          // Completion percentage
          Expanded(
            child: _buildStatColumn(
              icon: Icons.trending_up,
              value: '${(stats.percentage * 100).toStringAsFixed(0)}%',
              label: 'Complete',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search achievements...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  /// Build achievement list
  Widget _buildAchievementList(
    List<Achievement> achievements,
    Map<String, AchievementProgress> progress,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Sort: unlocked first, then by rarity, then by name
    final sortedAchievements = List<Achievement>.from(achievements)..sort((a, b) {
      final aUnlocked = progress[a.id]?.isUnlocked ?? false;
      final bUnlocked = progress[b.id]?.isUnlocked ?? false;

      // Unlocked first
      if (aUnlocked && !bUnlocked) return -1;
      if (!aUnlocked && bUnlocked) return 1;

      // Then by rarity (higher rarity first)
      final rarityCompare = b.rarity.index.compareTo(a.rarity.index);
      if (rarityCompare != 0) return rarityCompare;

      // Then by name
      return a.name.compareTo(b.name);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = sortedAchievements[index];
        final achievementProgress = progress[achievement.id];

        return AchievementCard(
          achievement: achievement,
          progress: achievementProgress,
          onTap: () => _onAchievementTap(achievement, achievementProgress),
        );
      },
    );
  }

  /// Filter achievements based on current filters
  List<Achievement> _filterAchievements(
    List<Achievement> achievements,
    Map<String, AchievementProgress> progress,
  ) {
    var filtered = achievements;

    // Filter by type (if selected)
    if (_selectedType != null) {
      filtered = filtered.where((a) => a.type == _selectedType).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) {
        final isUnlocked = progress[a.id]?.isUnlocked ?? false;
        // Hidden achievements can't be searched unless unlocked
        if (a.isHidden && !isUnlocked) return false;

        return a.name.toLowerCase().contains(_searchQuery) ||
            a.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filter by locked/unlocked
    if (_showOnlyUnlocked) {
      filtered = filtered.where((a) {
        return progress[a.id]?.isUnlocked ?? false;
      }).toList();
    }

    return filtered;
  }

  /// Handle achievement tap
  void _onAchievementTap(
    Achievement achievement,
    AchievementProgress? progress,
  ) {
    if (progress?.isUnlocked == true && !progress!.hasViewed) {
      // Mark as viewed
      ref.read(achievementControllerProvider.notifier).markAsViewed(achievement.id);
    }

    // Show details dialog
    _showAchievementDetails(achievement, progress);
  }

  /// Show achievement details dialog
  void _showAchievementDetails(
    Achievement achievement,
    AchievementProgress? progress,
  ) {
    final isUnlocked = progress?.isUnlocked ?? false;
    final isHidden = achievement.isHidden && !isUnlocked;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHidden ? '???' : achievement.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Text(
                isHidden ? '🔒' : achievement.icon,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              isHidden ? 'Hidden achievement' : achievement.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Details
            _buildDetailRow('Type', _formatTypeName(achievement.type)),
            _buildDetailRow('Rarity', achievement.rarityName),
            _buildDetailRow('Points', '${achievement.points}'),

            if (isUnlocked && progress?.unlockedAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                'Unlocked',
                _formatFullDate(progress!.unlockedAt!),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (isUnlocked)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature coming soon!'),
                  ),
                );
              },
              child: const Text('Share'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Format achievement type name
  String _formatTypeName(AchievementType type) {
    final name = type.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Format full date
  String _formatFullDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
