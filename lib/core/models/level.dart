import '../engine/container.dart';
import 'game_color.dart';

/// Represents a puzzle level configuration.
///
/// GAME DESIGN CONCEPT: Level as Pure Data
///
/// A Level is immutable configuration data that defines:
/// - Initial state (how containers start)
/// - Win conditions (implicitly: all containers solved)
/// - Difficulty metrics (move limit, complexity)
///
/// Think of this like:
/// - Database schema: Defines structure but not runtime state
/// - Recipe: Instructions, not the actual cooked meal
/// - Blueprint: Design, not the built house
///
/// The Level defines WHAT to play, GameState tracks HOW it's being played.
///
/// BACKEND ANALOGY:
/// This is like a JSON configuration file or database record.
/// In a web app, you'd store this in PostgreSQL/MongoDB.
/// The game state (current moves) would be in Redis/session storage.
enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Color coding for UI
  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'Perfect for beginners';
      case Difficulty.medium:
        return 'Requires some planning';
      case Difficulty.hard:
        return 'Challenging puzzles';
      case Difficulty.expert:
        return 'For puzzle masters';
    }
  }
}

/// Immutable level configuration.
///
/// WHY IMMUTABLE?
/// 1. Levels never change during gameplay (only game state changes)
/// 2. Can be safely shared across multiple game instances
/// 3. Can be cached/preloaded without worry
/// 4. Easy to serialize/deserialize from JSON
/// 5. Thread-safe for async loading
class Level {
  /// Unique identifier for this level
  /// Example: "level_1", "daily_2024_01_15", "custom_abc123"
  final String id;

  /// Human-readable name
  /// Example: "First Steps", "Rainbow Challenge"
  final String name;

  /// Initial container configuration
  ///
  /// IMPORTANT: This is the STARTING state, not current state.
  /// When a level is loaded, GameState is initialized from this.
  ///
  /// Example for a 3-color, 2-container level:
  /// ```dart
  /// [
  ///   Container.withColors(id: '1', colors: [red, blue, red]),
  ///   Container.withColors(id: '2', colors: [blue, red, blue]),
  ///   Container.empty(id: '3'),
  /// ]
  /// ```
  final List<Container> initialContainers;

  /// Maximum allowed moves before losing (optional)
  ///
  /// - null = unlimited moves (practice mode)
  /// - int > 0 = hard limit (competitive mode)
  ///
  /// This creates different play styles:
  /// - Casual: null limit, focus on solving
  /// - Challenge: tight limit, requires optimization
  final int? moveLimit;

  /// Difficulty rating
  ///
  /// Used for:
  /// - Level selection UI (filtering, sorting)
  /// - Hint system (more aggressive hints on easy)
  /// - Analytics (completion rates by difficulty)
  final Difficulty difficulty;

  /// Optional description or hint
  final String? description;

  /// Star thresholds for scoring (moves required for 1, 2, 3 stars)
  ///
  /// Example: [20, 15, 10] means:
  /// - 3 stars: solve in <= 10 moves
  /// - 2 stars: solve in <= 15 moves
  /// - 1 star: solve in <= 20 moves
  /// - 0 stars: solve in > 20 moves (or unlimited if null)
  ///
  /// null = no star system (just solve/not solved)
  final List<int>? starThresholds;

  const Level({
    required this.id,
    required this.name,
    required this.initialContainers,
    required this.difficulty,
    this.moveLimit,
    this.description,
    this.starThresholds,
  });

  // ==================== COMPUTED PROPERTIES ====================

  /// Number of containers in this level
  int get containerCount => initialContainers.length;

  /// Total number of colors to sort
  ///
  /// Useful for complexity estimation
  int get totalColors {
    return initialContainers.fold(
      0,
      (sum, container) => sum + container.colors.length,
    );
  }

  /// Estimated difficulty score (higher = harder)
  ///
  /// ALGORITHM: Simple heuristic based on:
  /// - Container count (more = harder)
  /// - Total colors (more = harder)
  /// - Move limit (stricter = harder)
  ///
  /// This could be enhanced with:
  /// - Color distribution analysis
  /// - Required move sequence complexity
  /// - Number of empty containers vs full
  double get complexityScore {
    double score = 0;

    // Base: containers and colors
    score += containerCount * 2;
    score += totalColors * 0.5;

    // Penalty for strict move limits
    if (moveLimit != null) {
      final moveRatio = totalColors / moveLimit!;
      score += moveRatio * 5; // Tighter limits = much harder
    }

    // Difficulty multiplier
    switch (difficulty) {
      case Difficulty.easy:
        score *= 0.5;
        break;
      case Difficulty.medium:
        score *= 1.0;
        break;
      case Difficulty.hard:
        score *= 1.5;
        break;
      case Difficulty.expert:
        score *= 2.0;
        break;
    }

    return score;
  }

  /// Calculate star rating for a given move count
  ///
  /// Returns 0-3 stars based on performance
  int calculateStars(int moveCount) {
    if (starThresholds == null || starThresholds!.length != 3) {
      return 0; // No star system
    }

    // Check thresholds (3 star, 2 star, 1 star)
    if (moveCount <= starThresholds![2]) return 3;
    if (moveCount <= starThresholds![1]) return 2;
    if (moveCount <= starThresholds![0]) return 1;
    return 0;
  }

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a simple tutorial level
  ///
  /// Perfect for teaching mechanics - 3 colors, multiple containers
  /// Solution: Sort colors so each container has only one color type
  factory Level.tutorial({String id = 'tutorial_1'}) {
    return Level(
      id: id,
      name: 'Tutorial: Color Sorting',
      difficulty: Difficulty.easy,
      description: 'Sort the colors so each container has only one color',
      initialContainers: [
        // Container 1: Red and Blue mixed
        Container.withColors(
          id: '1',
          colors: const [GameColor.red, GameColor.blue, GameColor.red],
          capacity: 4,
        ),
        // Container 2: Blue and Red mixed
        Container.withColors(
          id: '2',
          colors: const [GameColor.blue, GameColor.red, GameColor.blue],
          capacity: 4,
        ),
        // Container 3: Empty helper container
        Container.empty(id: '3', capacity: 4),
        // Container 4: Empty helper container
        Container.empty(id: '4', capacity: 4),
      ],
      moveLimit: 12, // Generous move limit for learning
      starThresholds: const [10, 8, 6], // 1 star: 10 moves, 2 stars: 8, 3 stars: 6
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert to JSON for storage/network
  ///
  /// Used for:
  /// - Saving custom levels
  /// - Loading from server
  /// - Level editor export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty.name,
      'description': description,
      'moveLimit': moveLimit,
      'starThresholds': starThresholds,
      'initialContainers': initialContainers.map((c) => {
        'id': c.id,
        'colors': c.colors.map((color) => color.name).toList(),
        'capacity': c.capacity,
      }).toList(),
    };
  }

  /// Create from JSON
  ///
  /// Handles parsing and validation
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      description: json['description'] as String?,
      moveLimit: json['moveLimit'] as int?,
      starThresholds: (json['starThresholds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      initialContainers: (json['initialContainers'] as List<dynamic>)
          .map((containerJson) {
            final colors = (containerJson['colors'] as List<dynamic>)
                .map((colorName) => GameColor.values.byName(colorName as String))
                .toList();

            return Container.withColors(
              id: containerJson['id'] as String,
              colors: colors,
              capacity: containerJson['capacity'] as int? ?? 4,
            );
          })
          .toList(),
    );
  }

  // ==================== IMMUTABLE COPY ====================

  /// Create a copy with modifications
  ///
  /// Useful for level editor or difficulty adjustments
  Level copyWith({
    String? id,
    String? name,
    List<Container>? initialContainers,
    int? moveLimit,
    Difficulty? difficulty,
    String? description,
    List<int>? starThresholds,
  }) {
    return Level(
      id: id ?? this.id,
      name: name ?? this.name,
      initialContainers: initialContainers ?? this.initialContainers,
      moveLimit: moveLimit ?? this.moveLimit,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      starThresholds: starThresholds ?? this.starThresholds,
    );
  }

  // ==================== EQUALITY & DEBUGGING ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Level) return false;

    return id == other.id &&
        name == other.name &&
        difficulty == other.difficulty &&
        description == other.description &&
        moveLimit == other.moveLimit &&
        _listEquals(starThresholds, other.starThresholds) &&
        _containersEqual(initialContainers, other.initialContainers);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    difficulty,
    description,
    moveLimit,
    Object.hashAll(starThresholds ?? []),
    Object.hashAll(initialContainers),
  );

  @override
  String toString() {
    return 'Level(id: $id, name: $name, difficulty: ${difficulty.name}, '
        'containers: $containerCount, moveLimit: $moveLimit)';
  }

  // Helper for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _containersEqual(List<Container> a, List<Container> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
