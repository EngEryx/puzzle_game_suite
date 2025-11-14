# Puzzle Game Suite - Usage Guide

## Quick Start

### Prerequisites
- Flutter 3.38.1 or higher
- Dart 3.10.0 or higher
- Android Studio / Xcode (for emulators)
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/EngEryx/puzzle_game_suite.git
cd puzzle_game_suite
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d ios-simulator
```

4. **Run tests**
```bash
flutter test
```

---

## Game Features

### 1. Home Screen
The entry point where you see:
- Game title and branding
- Progress summary (levels completed, stars earned, achievements)
- Navigation buttons:
  - **Levels** - Browse and play levels
  - **Quick Play** - Start tutorial level immediately
  - **Achievements** - View unlocked achievements
  - **Settings** - Configure game preferences

### 2. Level Selection
Browse all 200 levels organized by theme and difficulty:
- **Themes**: Ocean (Water), Forest (Nuts & Bolts), Desert (Balls), Space (Test Tubes)
- **Difficulties**: Easy, Medium, Hard, Expert
- **Filters**: Filter levels by difficulty or theme
- **Progress Indicators**:
  - Locked (gray) - Not yet unlocked
  - Unlocked (blue) - Available to play
  - In Progress (orange) - Started but not completed
  - Completed (green) - Finished with star rating

**How to unlock levels**: Complete levels sequentially. Each completed level unlocks the next.

### 3. Gameplay

#### Objective
Sort all colors so each container has only one color and is completely full, or is empty.

#### Controls
**Two-Tap System**:
1. Tap a container to select it (source)
2. Tap another container to pour (target)
3. Colors will pour from source to target

**Buttons**:
- **Undo** (↶) - Undo last move (if available)
- **Reset** (⟳) - Restart level from beginning
- **Hint** (💡) - Get AI-powered hint (3 free per level)

#### Rules
1. Can only pour from non-empty containers
2. Can only pour into non-full containers
3. Can pour into empty containers anytime
4. Can only pour matching colors (e.g., red → red)
5. Move counter tracks total moves

#### Win Conditions
Complete the puzzle to win. Star rating based on moves:
- **3 Stars** - Optimal or near-optimal (efficient)
- **2 Stars** - Good (reasonable moves)
- **1 Star** - Completed (many moves)

#### Loss Condition
If the level has a move limit and you exceed it, you lose. Must restart.

### 4. Hints System

#### Free Hints
- 3 free hints per level
- 30-second cooldown between uses
- Resets when you complete or restart the level

#### Paid Hints
- Cost: 10 coins per hint
- No cooldown
- Use when free hints are exhausted

#### How Hints Work
1. Tap the hint button (💡)
2. If free hints available, one is used
3. Hint overlay shows the recommended move
4. Red glow on source container
5. Green glow on target container
6. Arrows indicate pour direction
7. Tap anywhere to dismiss
8. Execute the move or ignore the hint

**Hint Quality**: AI uses BFS algorithm to find optimal solutions. Hints lead to winning moves.

### 5. Themes

Four unique visual themes, each with distinct art style:

#### Water Sort (Ocean Theme)
- Translucent liquid colors
- Water ripple effects
- Ocean-themed gradient backgrounds
- Smooth pour animations

#### Nuts & Bolts (Forest Theme)
- Metallic solid colors
- Hexagonal bolt shapes
- Industrial forest background
- Threading visualization

#### Ball Sort (Desert Theme)
- Glossy 3D sphere rendering
- Desert sand gradients
- Ball bounce physics
- Shadow effects

#### Test Tubes (Space Theme)
- Scientific gradient tubes
- Space-themed backgrounds
- Liquid pour effects
- Bubble animations

**Change Theme**: Settings → Visual → Game Theme

### 6. Settings

#### Audio Settings
- **Sound Effects** - Toggle SFX on/off
- **SFX Volume** - 0-100% volume slider
- **Music** - Toggle background music
- **Music Volume** - 0-100% volume slider
- **Master Volume** - Overall volume control
- **Haptic Feedback** - Vibration on actions

#### Visual Settings
- **Game Theme** - Select from 4 themes
- **Particle Effects** - Confetti, sparkles on win
- **Animations** - Enable/disable smooth animations
- **Reduced Motion** - Accessibility mode (minimal animation)
- **Brightness** - Light or Dark mode

#### Gameplay Settings
- **Hint Cooldown** - Time between free hints (10-300s)
- **Show Timer** - Display elapsed time
- **Auto Save** - Automatically save progress
- **Confirm Undo** - Require confirmation before undo
- **Show Moves Count** - Display move counter

#### About
- **About** - App version and info
- **Credits** - Development team
- **Privacy Policy** - Data handling info
- **Rate App** - Leave a review (coming soon)

**Reset Settings**: Tap the refresh icon in top-right of Settings screen.

### 7. Achievements

28 achievements across 7 categories:

#### Categories
1. **Progression** - Complete levels
   - First Steps, Level 10, Level 50, Level 100, Century Club, All Levels

2. **Mastery** - Perfect performance
   - Perfect Level, Perfect 10, Perfect 25, Star Collector

3. **Efficiency** - Optimal solutions
   - Efficient, Speed Demon, Minimalist, No Mistakes

4. **Exploration** - Try all themes
   - Theme Explorer, Theme Master

5. **Collection** - Earn stars
   - Star Gazer, Rising Star, Super Star, Ultimate Star

6. **Challenge** - Difficult achievements
   - Hard Mode, Expert Mode, No Hints, Undo Master

7. **Special** - Hidden achievements
   - Lucky Number, Secret achievements

**View Progress**: Achievements screen shows:
- Total achievements unlocked
- Total points earned (460 max)
- Search/filter by category or rarity
- Progress bars for in-progress achievements

---

## Tips & Strategies

### Beginner Tips
1. **Plan Ahead** - Think before you pour
2. **Use Empty Containers** - They're versatile temporary storage
3. **Free Hints** - Don't hesitate to use free hints early
4. **Undo Liberally** - Undo is free and unlimited
5. **Study Solutions** - Learn from AI hints to improve

### Advanced Strategies
1. **Reverse Engineering** - Start from the end state
2. **Color Isolation** - Isolate one color at a time
3. **Chain Moves** - Plan multi-move sequences
4. **Container Roles** - Assign containers as temporary vs final
5. **Minimal Moves** - Aim for 3-star efficiency

### Theme-Specific Tips
- **Water Sort** - Easier to see liquid levels
- **Nuts & Bolts** - Count bolts carefully
- **Ball Sort** - Watch for shadow depth cues
- **Test Tubes** - Use gradient boundaries

### Star Hunting
- Check star thresholds before starting
- Use hints to find optimal path
- Practice levels for better scores
- Study level patterns

---

## Troubleshooting

### App Won't Launch
1. Check Flutter installation: `flutter doctor`
2. Ensure dependencies installed: `flutter pub get`
3. Try cleaning: `flutter clean && flutter pub get`
4. Check device connection: `flutter devices`

### Performance Issues
1. Check device tier in logs
2. Disable particle effects: Settings → Visual → Particle Effects
3. Enable reduced motion: Settings → Visual → Reduced Motion
4. Restart app

### Audio Not Playing
1. Check Settings → Audio → Sound Effects (enabled?)
2. Check Settings → Audio → Master Volume (>0?)
3. Check device volume
4. Restart app

### Progress Not Saving
1. Check Settings → Gameplay → Auto Save (enabled?)
2. Ensure storage permissions granted
3. Check available storage space
4. Try manual save (complete a level)

### Levels Not Unlocking
Levels unlock sequentially. Complete the previous level to unlock the next.

### Hints Not Working
1. Check free hints remaining (top of hint button)
2. Wait for cooldown (30s between free hints)
3. Check coin balance for paid hints
4. Ensure level is solvable (all levels validated)

---

## Development Guide

### Project Structure
```
lib/
├── core/              # Core game logic and services
│   ├── engine/       # Immutable game engine
│   ├── models/       # Data models
│   └── services/     # Infrastructure (audio, storage)
├── features/         # Feature modules
│   ├── game/         # Gameplay UI and controllers
│   ├── levels/       # Level selection
│   ├── settings/     # Settings screen
│   ├── achievements/ # Achievement system
│   └── home/         # Home screen
├── shared/           # Reusable widgets
├── config/           # App configuration (routes, theme)
├── data/             # Generated data (levels)
└── main.dart         # App entry point
```

### Adding a New Theme

1. **Create theme class** (`lib/core/models/game_theme.dart`)
```dart
class MyNewTheme implements GameTheme {
  @override
  String get name => 'My Theme';

  @override
  ThemeType get type => ThemeType.myTheme;

  @override
  Color getColorForGameColor(GameColor color) {
    // Return theme-specific color
  }

  @override
  LinearGradient get backgroundGradient {
    // Return background gradient
  }
}
```

2. **Add theme type** (`lib/core/models/game_theme.dart`)
```dart
enum ThemeType {
  water, nutsBolts, balls, testTubes, myTheme
}
```

3. **Register in factory** (`lib/features/game/theme/theme_factory.dart`)
```dart
static GameTheme createTheme(ThemeType type) {
  return _cache.putIfAbsent(type, () {
    switch (type) {
      case ThemeType.myTheme:
        return MyNewTheme();
      // ... other cases
    }
  });
}
```

4. **Create custom painter** (optional)
```dart
class MyThemePainter extends ContainerPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Custom rendering
  }
}
```

### Adding New Levels

1. **Use level generator**
```bash
dart run bin/generate_levels.dart
```

2. **Or create manually** (`lib/data/levels/my_levels.dart`)
```dart
final myLevels = [
  Level(
    id: 'my_001',
    name: 'My Level 1',
    themeType: ThemeType.water,
    difficulty: Difficulty.easy,
    initialContainers: [
      Container(id: 'c1', colors: [GameColor.red, GameColor.blue]),
      Container(id: 'c2', colors: [GameColor.blue, GameColor.red]),
      Container.empty(id: 'c3'),
    ],
    moveLimit: 10,
    starThresholds: StarThresholds(
      threeStar: 4,
      twoStar: 6,
      oneStar: 10,
    ),
  ),
];
```

3. **Validate solvability**
```bash
dart run bin/test_all_levels.dart
```

### Adding Achievements

1. **Define achievement** (`lib/core/models/achievement.dart`)
```dart
final myAchievement = Achievement(
  id: 'my_achievement',
  name: 'My Achievement',
  description: 'Do something cool',
  category: AchievementCategory.special,
  rarity: AchievementRarity.rare,
  points: 25,
  icon: Icons.star,
  progressMax: 1, // 1 for unlock-based, >1 for progress
);
```

2. **Add to registry** (`lib/core/services/achievement_service.dart`)
```dart
static final allAchievements = [
  // ... existing
  myAchievement,
];
```

3. **Trigger achievement** (in game logic)
```dart
ref.read(achievementControllerProvider.notifier).checkAndUnlock(
  'my_achievement',
  progress: 1,
);
```

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/core/engine/container_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Building for Release

#### Android
```bash
# APK (for direct distribution)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Requires macOS with Xcode
flutter build ios --release
```

### Code Quality

```bash
# Run analyzer
flutter analyze

# Format code
flutter format lib/

# Fix common issues
dart fix --apply
```

---

## Advanced Features

### Performance Monitoring

The app includes built-in performance monitoring:
- Frame rate tracking
- Render time measurement
- Memory allocation tracking
- GC pause detection

**Enable Performance Overlay**: (Add to main.dart for debugging)
```dart
MaterialApp(
  showPerformanceOverlay: true, // Enable FPS overlay
  ...
)
```

### Device Tier Detection

The app automatically detects device capabilities:
- **Low Tier** - Older devices, reduced effects
- **Mid Tier** - Average devices, standard effects
- **High Tier** - Flagship devices, all effects

**Check Tier**: See logs on app start.

### Custom Animations

Animations use Flutter's animation framework:
- **Duration**: 300-800ms for most animations
- **Curves**: easeInOut for natural motion
- **Physics**: Spring physics for bounces

**Disable Animations**: Settings → Visual → Animations (off)

---

## FAQ

### How do I earn coins?
Currently, coins are earned through gameplay achievements. Monetization (coin purchases) coming in Week 7-8.

### Can I play offline?
Yes, the entire game works offline. No internet connection required.

### How is my data stored?
All data is stored locally on your device using SharedPreferences. No data is sent to external servers.

### Can I reset my progress?
Currently, progress reset is not available in settings. You can uninstall/reinstall the app to reset.

### Why are some levels locked?
Levels unlock sequentially. Complete each level to unlock the next.

### How do star ratings work?
Stars are based on move efficiency:
- 3 stars: Very efficient (close to optimal)
- 2 stars: Good (reasonable moves)
- 1 star: Completed (many moves)

### Can I replay completed levels?
Yes, tap any completed level to replay it and try for a better score.

### What happens when I run out of hints?
You can use paid hints (10 coins each) or wait for the cooldown to reset.

### Are levels randomly generated?
No, all 200 levels are hand-validated and guaranteed solvable.

### Can I change difficulty mid-game?
No, difficulty is per-level. Choose easier/harder levels from the Level Selector.

---

## Support & Feedback

### Reporting Bugs
1. Check if the issue is already known (see Known Issues in PROJECT_STATUS.md)
2. Note steps to reproduce
3. Include device info (Android version, device model)
4. Contact via GitHub issues (coming soon)

### Feature Requests
We're actively developing! Current roadmap through Week 12. Future updates may include requested features.

### Contributing
This is a commercial project for Truth Wireless Limited. External contributions are not currently accepted.

---

## Credits

**Development**: Eryx Labs Team
**UI/UX**: Material Design 3
**Game Engine**: Flutter
**State Management**: Riverpod
**Sound Effects**: Freesound.org
**Icons**: Material Icons

---

## Version History

### Version 1.0.0 (Week 6 - Current)
- Complete core gameplay
- 200 levels across 4 themes
- AI hint system
- Achievement system (28 achievements)
- Comprehensive settings
- Performance optimizations

### Upcoming
- **1.1.0 (Week 8)** - Monetization (ads, IAP)
- **1.2.0 (Week 10)** - Production polish
- **1.5.0 (Week 12)** - Official launch

---

**Last Updated**: 2025-11-14
**Version**: 1.0.0+1 (Week 6)
