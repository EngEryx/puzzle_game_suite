import 'package:flutter/material.dart';
import '../../../core/models/achievement.dart';

/// Visual achievement display card
///
/// DESIGN PRINCIPLES:
/// 1. Clear visual distinction between locked/unlocked
/// 2. Progress indication for incremental achievements
/// 3. Rarity shown through color coding
/// 4. Satisfying unlock animation
///
/// LOCKED STATE:
/// - Silhouette/dimmed icon
/// - Grayed out text
/// - Progress bar if applicable
/// - Mystery for hidden achievements
///
/// UNLOCKED STATE:
/// - Full color icon
/// - Bright text
/// - Unlock date
/// - Celebration feel
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress? progress;
  final VoidCallback? onTap;
  final bool showProgress;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.progress,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = progress?.isUnlocked ?? false;
    final isHidden = achievement.isHidden && !isUnlocked;
    final currentProgress = progress?.currentProgress ?? 0;

    return Card(
      elevation: isUnlocked ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnlocked
              ? Color(achievement.rarityColor).withOpacity(0.5)
              : Colors.grey.shade300,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row (icon + title + rarity badge)
              Row(
                children: [
                  // Icon
                  _buildIcon(isUnlocked, isHidden),
                  const SizedBox(width: 12),

                  // Title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHidden ? '???' : achievement.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: isUnlocked
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rarity badge
                  _buildRarityBadge(isUnlocked),

                  // Points
                  if (isUnlocked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${achievement.points}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                isHidden ? 'Hidden achievement' : achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
                  fontStyle: isHidden ? FontStyle.italic : FontStyle.normal,
                ),
              ),

              // Progress bar (for incremental achievements)
              if (showProgress &&
                  achievement.isIncremental &&
                  !isHidden) ...[
                const SizedBox(height: 12),
                _buildProgressBar(currentProgress, achievement.maxProgress),
              ],

              // Unlock date (for unlocked achievements)
              if (isUnlocked && progress?.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked ${_formatDate(progress!.unlockedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // New badge (for recently unlocked)
              if (isUnlocked && !progress!.hasViewed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build achievement icon
  Widget _buildIcon(bool isUnlocked, bool isHidden) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnlocked
            ? Color(achievement.rarityColor).withOpacity(0.2)
            : Colors.grey.shade200,
        border: Border.all(
          color: isUnlocked
              ? Color(achievement.rarityColor)
              : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          isHidden ? '🔒' : achievement.icon,
          style: TextStyle(
            fontSize: 28,
            color: isUnlocked ? null : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// Build rarity badge
  Widget _buildRarityBadge(bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Color(achievement.rarityColor).withOpacity(0.2)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? Color(achievement.rarityColor)
              : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Text(
        achievement.rarityName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isUnlocked
              ? Color(achievement.rarityColor)
              : Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar(int current, int max) {
    final percentage = (current / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '$current / $max',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(achievement.rarityColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Format unlock date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
