import '../models/achievement.dart';

/// Predefined achievements for the game
///
/// ACHIEVEMENT DESIGN PHILOSOPHY:
///
/// 1. BALANCED DIFFICULTY CURVE
///    - 40% Common (easy, most players unlock)
///    - 30% Uncommon (moderate effort)
///    - 20% Rare (skilled players)
///    - 8% Epic (dedicated players)
///    - 2% Legendary (hardcore completionists)
///
/// 2. PSYCHOLOGICAL MOTIVATORS
///    - Early wins (unlock first achievement quickly)
///    - Incremental goals (10, 25, 50, 100, 200)
///    - Surprising discoveries (hidden achievements)
///    - Social bragging rights (rare achievements)
///
/// 3. VARIED PLAY STYLES
///    - Progression achievements (everyone gets these)
///    - Mastery achievements (skilled play)
///    - Exploration achievements (try everything)
///    - Collection achievements (completionists)
///
/// Total: 28 achievements, 460 points available
class AchievementDefinitions {
  // ==================== LEVEL COMPLETION ACHIEVEMENTS ====================

  static final firstSteps = Achievement(
    id: 'first_steps',
    name: 'First Steps',
    description: 'Complete your first level',
    icon: '🎯',
    type: AchievementType.level,
    rarity: AchievementRarity.common,
    requirement: {'type': 'levelCount', 'count': 1},
    maxProgress: 1,
    points: 5,
  );

  static final gettingStarted = Achievement(
    id: 'getting_started',
    name: 'Getting Started',
    description: 'Complete 10 levels',
    icon: '🚀',
    type: AchievementType.level,
    rarity: AchievementRarity.common,
    requirement: {'type': 'levelCount', 'count': 10},
    maxProgress: 10,
    points: 10,
  );

  static final puzzleEnthusiast = Achievement(
    id: 'puzzle_enthusiast',
    name: 'Puzzle Enthusiast',
    description: 'Complete 50 levels',
    icon: '⭐',
    type: AchievementType.level,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'levelCount', 'count': 50},
    maxProgress: 50,
    points: 20,
  );

  static final centurion = Achievement(
    id: 'centurion',
    name: 'Centurion',
    description: 'Complete 100 levels',
    icon: '💯',
    type: AchievementType.level,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'levelCount', 'count': 100},
    maxProgress: 100,
    points: 30,
  );

  static final puzzleMaster = Achievement(
    id: 'puzzle_master',
    name: 'Puzzle Master',
    description: 'Complete 200 levels',
    icon: '🏆',
    type: AchievementType.level,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'levelCount', 'count': 200},
    maxProgress: 200,
    points: 50,
  );

  // ==================== STAR COLLECTION ACHIEVEMENTS ====================

  static final starGazer = Achievement(
    id: 'star_gazer',
    name: 'Star Gazer',
    description: 'Earn 10 stars',
    icon: '⭐',
    type: AchievementType.star,
    rarity: AchievementRarity.common,
    requirement: {'type': 'stars', 'count': 10},
    maxProgress: 10,
    points: 5,
  );

  static final starCollector = Achievement(
    id: 'star_collector',
    name: 'Star Collector',
    description: 'Earn 50 stars',
    icon: '🌟',
    type: AchievementType.star,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'stars', 'count': 50},
    maxProgress: 50,
    points: 15,
  );

  static final stellarPerformer = Achievement(
    id: 'stellar_performer',
    name: 'Stellar Performer',
    description: 'Earn 150 stars',
    icon: '✨',
    type: AchievementType.star,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'stars', 'count': 150},
    maxProgress: 150,
    points: 25,
  );

  static final constellationMaster = Achievement(
    id: 'constellation_master',
    name: 'Constellation Master',
    description: 'Earn 300 stars',
    icon: '🌌',
    type: AchievementType.star,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'stars', 'count': 300},
    maxProgress: 300,
    points: 40,
  );

  static final superNova = Achievement(
    id: 'super_nova',
    name: 'Super Nova',
    description: 'Earn 500 stars',
    icon: '💫',
    type: AchievementType.star,
    rarity: AchievementRarity.legendary,
    requirement: {'type': 'stars', 'count': 500},
    maxProgress: 500,
    points: 60,
  );

  // ==================== PERFECT PLAY ACHIEVEMENTS ====================

  static final perfectionist = Achievement(
    id: 'perfectionist',
    name: 'Perfectionist',
    description: 'Complete 5 levels with 3 stars',
    icon: '💎',
    type: AchievementType.perfect,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'perfectCount', 'count': 5},
    maxProgress: 5,
    points: 15,
  );

  static final flawlessVictory = Achievement(
    id: 'flawless_victory',
    name: 'Flawless Victory',
    description: 'Complete 25 levels with 3 stars',
    icon: '💠',
    type: AchievementType.perfect,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'perfectCount', 'count': 25},
    maxProgress: 25,
    points: 30,
  );

  static final absolutePerfection = Achievement(
    id: 'absolute_perfection',
    name: 'Absolute Perfection',
    description: 'Complete 50 levels with 3 stars',
    icon: '👑',
    type: AchievementType.perfect,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'perfectCount', 'count': 50},
    maxProgress: 50,
    points: 50,
  );

  // ==================== DIFFICULTY ACHIEVEMENTS ====================

  static final hardcoreGamer = Achievement(
    id: 'hardcore_gamer',
    name: 'Hardcore Gamer',
    description: 'Complete 10 hard levels',
    icon: '🔥',
    type: AchievementType.difficulty,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'difficultyComplete', 'difficulty': 'hard', 'count': 10},
    maxProgress: 10,
    points: 25,
  );

  static final expertSolver = Achievement(
    id: 'expert_solver',
    name: 'Expert Solver',
    description: 'Complete 10 expert levels',
    icon: '🧠',
    type: AchievementType.difficulty,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'difficultyComplete', 'difficulty': 'expert', 'count': 10},
    maxProgress: 10,
    points: 40,
  );

  // ==================== EFFICIENCY ACHIEVEMENTS ====================

  static final efficientSolver = Achievement(
    id: 'efficient_solver',
    name: 'Efficient Solver',
    description: 'Complete 10 levels under par',
    icon: '⚡',
    type: AchievementType.efficiency,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'underPar', 'count': 10},
    maxProgress: 10,
    points: 15,
  );

  static final speedDemon = Achievement(
    id: 'speed_demon',
    name: 'Speed Demon',
    description: 'Complete a level in under 10 moves',
    icon: '🏃',
    type: AchievementType.speed,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'fastCompletion', 'moves': 10},
    maxProgress: 1,
    points: 20,
  );

  static final lightningFast = Achievement(
    id: 'lightning_fast',
    name: 'Lightning Fast',
    description: 'Complete a level in under 5 moves',
    icon: '⚡',
    type: AchievementType.speed,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'fastCompletion', 'moves': 5},
    maxProgress: 1,
    points: 35,
    isHidden: true,
  );

  // ==================== THEME ACHIEVEMENTS ====================

  static final waterMaster = Achievement(
    id: 'water_master',
    name: 'Water Master',
    description: 'Complete all water theme levels',
    icon: '💧',
    type: AchievementType.theme,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'themeComplete', 'themeId': 'water'},
    maxProgress: 1,
    points: 25,
  );

  static final ballSorter = Achievement(
    id: 'ball_sorter',
    name: 'Ball Sorter',
    description: 'Complete all ball theme levels',
    icon: '⚽',
    type: AchievementType.theme,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'themeComplete', 'themeId': 'ball'},
    maxProgress: 1,
    points: 25,
  );

  static final testTubeExpert = Achievement(
    id: 'test_tube_expert',
    name: 'Test Tube Expert',
    description: 'Complete all test tube theme levels',
    icon: '🧪',
    type: AchievementType.theme,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'themeComplete', 'themeId': 'test_tube'},
    maxProgress: 1,
    points: 25,
  );

  static final themeMaster = Achievement(
    id: 'theme_master',
    name: 'Theme Master',
    description: 'Complete all levels in all themes',
    icon: '🎨',
    type: AchievementType.theme,
    rarity: AchievementRarity.legendary,
    requirement: {'type': 'allThemesComplete'},
    maxProgress: 1,
    points: 60,
  );

  // ==================== HINT-FREE ACHIEVEMENTS ====================

  static final independentThinker = Achievement(
    id: 'independent_thinker',
    name: 'Independent Thinker',
    description: 'Complete 10 levels without using hints',
    icon: '🤔',
    type: AchievementType.hintFree,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'hintFree', 'count': 10},
    maxProgress: 10,
    points: 15,
  );

  static final purist = Achievement(
    id: 'purist',
    name: 'Purist',
    description: 'Complete 50 levels without using hints',
    icon: '🧘',
    type: AchievementType.hintFree,
    rarity: AchievementRarity.rare,
    requirement: {'type': 'hintFree', 'count': 50},
    maxProgress: 50,
    points: 30,
  );

  // ==================== SPECIAL / HIDDEN ACHIEVEMENTS ====================

  static final undoNever = Achievement(
    id: 'undo_never',
    name: 'No Regrets',
    description: 'Complete a level without using undo',
    icon: '🎯',
    type: AchievementType.special,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'noUndo'},
    maxProgress: 1,
    points: 15,
    isHidden: true,
  );

  static final oneShotOneDream = Achievement(
    id: 'one_shot_one_dream',
    name: 'One Shot, One Dream',
    description: 'Complete a hard level on first try without undo',
    icon: '🎲',
    type: AchievementType.special,
    rarity: AchievementRarity.epic,
    requirement: {'type': 'firstTryNoUndo', 'difficulty': 'hard'},
    maxProgress: 1,
    points: 40,
    isHidden: true,
  );

  static final nightOwl = Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: 'Complete a level after midnight',
    icon: '🦉',
    type: AchievementType.special,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'lateNight'},
    maxProgress: 1,
    points: 10,
    isHidden: true,
  );

  static final earlyBird = Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Complete a level before 6 AM',
    icon: '🐦',
    type: AchievementType.special,
    rarity: AchievementRarity.uncommon,
    requirement: {'type': 'earlyMorning'},
    maxProgress: 1,
    points: 10,
    isHidden: true,
  );

  // ==================== ALL ACHIEVEMENTS LIST ====================

  /// Complete list of all achievements
  static final List<Achievement> all = [
    // Level achievements
    firstSteps,
    gettingStarted,
    puzzleEnthusiast,
    centurion,
    puzzleMaster,

    // Star achievements
    starGazer,
    starCollector,
    stellarPerformer,
    constellationMaster,
    superNova,

    // Perfect achievements
    perfectionist,
    flawlessVictory,
    absolutePerfection,

    // Difficulty achievements
    hardcoreGamer,
    expertSolver,

    // Efficiency achievements
    efficientSolver,
    speedDemon,
    lightningFast,

    // Theme achievements
    waterMaster,
    ballSorter,
    testTubeExpert,
    themeMaster,

    // Hint-free achievements
    independentThinker,
    purist,

    // Special achievements
    undoNever,
    oneShotOneDream,
    nightOwl,
    earlyBird,
  ];

  /// Get achievements by category for organized display
  static Map<String, List<Achievement>> getByCategory() {
    return {
      'Progression': [
        firstSteps,
        gettingStarted,
        puzzleEnthusiast,
        centurion,
        puzzleMaster,
      ],
      'Star Collection': [
        starGazer,
        starCollector,
        stellarPerformer,
        constellationMaster,
        superNova,
      ],
      'Mastery': [
        perfectionist,
        flawlessVictory,
        absolutePerfection,
        hardcoreGamer,
        expertSolver,
      ],
      'Efficiency': [
        efficientSolver,
        speedDemon,
        lightningFast,
      ],
      'Themes': [
        waterMaster,
        ballSorter,
        testTubeExpert,
        themeMaster,
      ],
      'Challenge': [
        independentThinker,
        purist,
        undoNever,
        oneShotOneDream,
      ],
      'Special': [
        nightOwl,
        earlyBird,
      ],
    };
  }
}
