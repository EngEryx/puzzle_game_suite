/// Achievement data model
///
/// GAMIFICATION PSYCHOLOGY:
///
/// Achievements tap into multiple psychological motivators:
/// 1. MASTERY - Proving skill and expertise
/// 2. COMPLETION - Satisfying the collector's instinct
/// 3. STATUS - Showing off rare accomplishments
/// 4. DISCOVERY - Finding hidden achievements
/// 5. PROGRESSION - Incremental goals that feel achievable
///
/// BEST PRACTICES:
/// - Mix easy and hard achievements (balanced difficulty curve)
/// - Include both incremental (50, 100, 200) and one-time achievements
/// - Some visible, some hidden (for surprise and delight)
/// - Varied achievement types to appeal to different player types
///
/// ACHIEVEMENT TYPES BY PLAYER PSYCHOLOGY:
/// - Achievers: Level milestones, perfect scores
/// - Explorers: Hidden achievements, special conditions
/// - Socializers: Share-worthy achievements
/// - Completionists: Collection-based (all themes, all stars)
///
/// Similar to:
/// - Steam Achievements
/// - Xbox Gamerscore
/// - PlayStation Trophies
/// - Mobile game badges
library;


/// Type of achievement
///
/// Categories help organize achievements and track different play styles
enum AchievementType {
  /// Level completion milestones (10, 50, 100, 200 levels)
  level,

  /// Star collection achievements (50, 150, 300 stars)
  star,

  /// Perfect completions (minimal moves)
  perfect,

  /// Speed-based achievements (time limits)
  speed,

  /// Theme-specific achievements (complete all levels in a theme)
  theme,

  /// No hints used
  hintFree,

  /// Daily engagement (consecutive days)
  daily,

  /// Special conditions (hidden achievements)
  special,

  /// Difficulty-based (complete all hard/expert levels)
  difficulty,

  /// Move efficiency (under par on multiple levels)
  efficiency,
}

/// Rarity of achievement
///
/// Determines visual presentation and bragging rights
enum AchievementRarity {
  /// Easy to get, most players will unlock
  common,

  /// Moderate difficulty, about half of players
  uncommon,

  /// Challenging, skilled players only
  rare,

  /// Very difficult, top 10% of players
  epic,

  /// Extremely rare, top 1% of players
  legendary,
}

/// Achievement model
///
/// Immutable data class representing a single achievement
class Achievement {
  /// Unique identifier
  final String id;

  /// Display name (e.g., "First Steps", "Speed Demon")
  final String name;

  /// Description of how to unlock
  final String description;

  /// Icon identifier (could be emoji, icon name, or asset path)
  final String icon;

  /// Type/category of achievement
  final AchievementType type;

  /// Rarity level
  final AchievementRarity rarity;

  /// Requirement to unlock (flexible format)
  ///
  /// Examples:
  /// - {"type": "levelCount", "count": 10}
  /// - {"type": "stars", "count": 50}
  /// - {"type": "perfectCount", "count": 5}
  /// - {"type": "theme", "themeId": "water", "complete": true}
  final Map<String, dynamic> requirement;

  /// Reward for unlocking (optional)
  ///
  /// Examples:
  /// - {"type": "coins", "amount": 100}
  /// - {"type": "theme", "id": "golden"}
  /// - null for no reward (achievement itself is reward)
  final Map<String, dynamic>? reward;

  /// Whether this achievement is hidden until unlocked
  ///
  /// Hidden achievements create surprise and encourage exploration
  final bool isHidden;

  /// Maximum progress value (for incremental achievements)
  ///
  /// Examples:
  /// - 100 for "Complete 100 levels"
  /// - 50 for "Earn 50 stars"
  /// - 1 for one-time achievements
  final int maxProgress;

  /// Point value (for total achievement score)
  ///
  /// Higher points for harder achievements
  final int points;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.requirement,
    this.reward,
    this.isHidden = false,
    this.maxProgress = 1,
    this.points = 10,
  });

  // ==================== COMPUTED PROPERTIES ====================

  /// Whether this is a one-time achievement (not incremental)
  bool get isOneTime => maxProgress == 1;

  /// Whether this is an incremental achievement (has progress tracking)
  bool get isIncremental => maxProgress > 1;

  /// Color associated with rarity
  ///
  /// Used for UI highlighting
  int get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return 0xFF9E9E9E; // Gray
      case AchievementRarity.uncommon:
        return 0xFF4CAF50; // Green
      case AchievementRarity.rare:
        return 0xFF2196F3; // Blue
      case AchievementRarity.epic:
        return 0xFF9C27B0; // Purple
      case AchievementRarity.legendary:
        return 0xFFFFD700; // Gold
    }
  }

  /// Display name for rarity
  String get rarityName {
    return rarity.name[0].toUpperCase() + rarity.name.substring(1);
  }

  // ==================== SERIALIZATION ====================

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.name,
      'rarity': rarity.name,
      'requirement': requirement,
      'reward': reward,
      'isHidden': isHidden,
      'maxProgress': maxProgress,
      'points': points,
    };
  }

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: AchievementType.values.byName(json['type'] as String),
      rarity: AchievementRarity.values.byName(json['rarity'] as String),
      requirement: Map<String, dynamic>.from(json['requirement'] as Map),
      reward: json['reward'] != null
          ? Map<String, dynamic>.from(json['reward'] as Map)
          : null,
      isHidden: json['isHidden'] as bool? ?? false,
      maxProgress: json['maxProgress'] as int? ?? 1,
      points: json['points'] as int? ?? 10,
    );
  }

  // ==================== EQUALITY ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Achievement) return false;

    return id == other.id &&
        name == other.name &&
        type == other.type &&
        rarity == other.rarity;
  }

  @override
  int get hashCode => Object.hash(id, name, type, rarity);

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, type: ${type.name}, rarity: ${rarity.name})';
  }

  /// Create a copy with modifications
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    Map<String, dynamic>? requirement,
    Map<String, dynamic>? reward,
    bool? isHidden,
    int? maxProgress,
    int? points,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      requirement: requirement ?? this.requirement,
      reward: reward ?? this.reward,
      isHidden: isHidden ?? this.isHidden,
      maxProgress: maxProgress ?? this.maxProgress,
      points: points ?? this.points,
    );
  }
}

/// Player progress towards an achievement
///
/// Tracks current progress and unlock status
class AchievementProgress {
  /// Achievement ID this progress belongs to
  final String achievementId;

  /// Current progress value (0 to achievement.maxProgress)
  final int currentProgress;

  /// Whether this achievement is unlocked
  final bool isUnlocked;

  /// Timestamp when unlocked (null if not unlocked)
  final DateTime? unlockedAt;

  /// Whether the player has viewed this achievement after unlocking
  ///
  /// Used to show "NEW!" badge
  final bool hasViewed;

  const AchievementProgress({
    required this.achievementId,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.hasViewed = false,
  });

  // ==================== COMPUTED PROPERTIES ====================

  /// Progress as a percentage (0.0 to 1.0)
  double progressPercentage(int maxProgress) {
    if (maxProgress == 0) return 0.0;
    return (currentProgress / maxProgress).clamp(0.0, 1.0);
  }

  /// Whether this achievement was recently unlocked (within 24 hours)
  bool get isRecentlyUnlocked {
    if (unlockedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(unlockedAt!);
    return difference.inHours < 24;
  }

  // ==================== SERIALIZATION ====================

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'hasViewed': hasViewed,
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      hasViewed: json['hasViewed'] as bool? ?? false,
    );
  }

  // ==================== COPY WITH ====================

  AchievementProgress copyWith({
    String? achievementId,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? hasViewed,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      hasViewed: hasViewed ?? this.hasViewed,
    );
  }

  @override
  String toString() {
    return 'AchievementProgress(id: $achievementId, progress: $currentProgress, unlocked: $isUnlocked)';
  }
}

/// Achievement statistics
///
/// Aggregate data for displaying achievement summary
class AchievementStats {
  /// Total number of achievements
  final int total;

  /// Number of unlocked achievements
  final int unlocked;

  /// Total achievement points earned
  final int points;

  /// Total possible achievement points
  final int maxPoints;

  const AchievementStats({
    required this.total,
    required this.unlocked,
    required this.points,
    required this.maxPoints,
  });

  /// Unlock percentage (0.0 to 1.0)
  double get percentage => total > 0 ? unlocked / total : 0.0;

  /// Point completion percentage (0.0 to 1.0)
  double get pointsPercentage => maxPoints > 0 ? points / maxPoints : 0.0;

  @override
  String toString() {
    return 'AchievementStats(unlocked: $unlocked/$total, points: $points/$maxPoints)';
  }
}
