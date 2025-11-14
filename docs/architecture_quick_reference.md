# Puzzle Game Architecture - Quick Reference

## Core Concepts Cheat Sheet

### Game State vs App State
```
App State (Traditional):
- User clicks button → API call → Update UI
- State changes are reactive to external events
- Focus: Data consistency, API sync

Game State:
- 60fps render loop constantly checking state
- State must be deterministic and predictable
- Focus: Performance, frame timing, smooth transitions
- Every frame asks: "What should I draw?"
```

### Key Architecture Pattern: Entity-Component-System (Simplified)

```
Entity: The game object (Container)
Component: Data that describes it (position, colors, capacity)
System: Logic that acts on it (move validator, renderer)

Why? Decouples data from behavior = testable, maintainable code
```

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── engine/
│   │   ├── container.dart          # Pure data model
│   │   ├── move.dart                # Move representation
│   │   ├── move_validator.dart     # Pure functions for rules
│   │   ├── game_state.dart         # Current game state
│   │   └── solver.dart              # AI hint system
│   ├── models/
│   │   ├── level.dart               # Level configuration
│   │   ├── theme.dart               # Theme data model
│   │   └── player_progress.dart    # Progression tracking
│   └── services/
│       ├── storage_service.dart     # Persistence
│       ├── analytics_service.dart   # Tracking
│       └── audio_service.dart       # Sound management
├── features/
│   ├── game/
│   │   ├── presentation/
│   │   │   ├── game_screen.dart     # Main game UI
│   │   │   ├── widgets/
│   │   │   │   ├── container_widget.dart
│   │   │   │   ├── game_board.dart
│   │   │   │   └── controls.dart
│   │   ├── controller/
│   │   │   └── game_controller.dart # Game loop & state mgmt
│   │   └── theme/
│   │       ├── water_theme.dart
│   │       ├── nuts_bolts_theme.dart
│   │       ├── ball_theme.dart
│   │       └── test_tube_theme.dart
│   ├── levels/
│   │   ├── level_selector_screen.dart
│   │   └── level_generator.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── shared/
│   ├── widgets/                     # Reusable UI components
│   ├── constants/                   # Game constants
│   └── utils/                       # Helper functions
└── config/
    ├── theme_config.dart            # App theme
    └── routes.dart                  # Navigation
```

---

## Core Classes

### Container (Pure Data)
```dart
class Container {
  final String id;
  final List<GameColor> colors;  // Bottom to top
  final int capacity;
  
  bool get isEmpty => colors.isEmpty;
  bool get isFull => colors.length >= capacity;
  bool get isSolved => colors.isEmpty || 
                       (isFull && colors.every((c) => c == colors.first));
  GameColor? get topColor => colors.isEmpty ? null : colors.last;
  
  // Immutable - returns new instance
  Container pourTo(Container other) { ... }
}
```

### Move (Value Object)
```dart
class Move {
  final String fromContainerId;
  final String toContainerId;
  final GameColor color;
  final int count;  // How many items moved
  
  Move reverse() => Move(
    fromContainerId: toContainerId,
    toContainerId: fromContainerId,
    color: color,
    count: count,
  );
}
```

### GameState (Immutable State)
```dart
class GameState {
  final List<Container> containers;
  final List<Move> moveHistory;
  final int moveCount;
  final bool isWon;
  final Level level;
  
  GameState copyWith({...}) { ... }
  GameState applyMove(Move move) { ... }
  GameState undo() { ... }
}
```

### MoveValidator (Pure Functions)
```dart
class MoveValidator {
  static bool canMove(Container from, Container to) {
    if (from.isEmpty) return false;
    if (to.isFull) return false;
    if (to.isEmpty) return true;
    return from.topColor == to.topColor;
  }
  
  static bool isGameWon(List<Container> containers) {
    return containers.every((c) => c.isSolved);
  }
}
```

---

## State Management Pattern (Riverpod)

```dart
// Game state provider
final gameStateProvider = StateNotifierProvider<GameController, GameState>(
  (ref) => GameController(ref.read(currentLevelProvider)),
);

// Game controller
class GameController extends StateNotifier<GameState> {
  GameController(Level level) : super(GameState.initial(level));
  
  void makeMove(String fromId, String toId) {
    final from = state.getContainer(fromId);
    final to = state.getContainer(toId);
    
    if (!MoveValidator.canMove(from, to)) return;
    
    final move = Move.create(from, to);
    state = state.applyMove(move);
    
    if (MoveValidator.isGameWon(state.containers)) {
      _handleWin();
    }
  }
  
  void undo() {
    if (state.moveHistory.isEmpty) return;
    state = state.undo();
  }
}
```

---

## Animation Pattern

```dart
class ContainerWidget extends StatefulWidget {
  final Container container;
  
  @override
  State<ContainerWidget> createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animController;
  late Animation<double> _pourAnimation;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pourAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }
  
  void animatePour() {
    _animController.forward(from: 0);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pourAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ContainerPainter(
            container: widget.container,
            pourProgress: _pourAnimation.value,
          ),
        );
      },
    );
  }
}
```

---

## Theme System Pattern

```dart
abstract class GameTheme {
  String get name;
  
  Widget buildContainer(Container container);
  Animation<double> getPourAnimation();
  Color getColorForType(GameColor color);
  String getSoundForPour();
  
  // Optional overrides
  Widget? buildBackground() => null;
  List<Shadow>? getContainerShadows() => null;
}

class WaterTheme implements GameTheme {
  @override
  Widget buildContainer(Container container) {
    return CustomPaint(
      painter: WaterContainerPainter(container),
    );
  }
  
  @override
  Color getColorForType(GameColor color) {
    return switch (color) {
      GameColor.red => Color(0xFFE74C3C).withOpacity(0.7),  // Translucent
      GameColor.blue => Color(0xFF3498DB).withOpacity(0.7),
      // ... more colors
    };
  }
}

class NutsAndBoltsTheme implements GameTheme {
  @override
  Color getColorForType(GameColor color) {
    return switch (color) {
      GameColor.red => Color(0xFFE74C3C),  // Solid, no translucency
      GameColor.blue => Color(0xFF3498DB),
      // ... more colors
    };
  }
}
```

---

## Performance Tips

### 1. Const Constructors
```dart
// Bad: Creates new widget every frame
return Container(child: Text('Hello'));

// Good: Reuses widget instance
return const SizedBox(child: const Text('Hello'));
```

### 2. RepaintBoundary
```dart
// Isolate expensive repaints
return RepaintBoundary(
  child: CustomPaint(
    painter: ExpensivePainter(),
  ),
);
```

### 3. Keys for Lists
```dart
// When containers can move/reorder
return ListView.builder(
  itemBuilder: (context, index) {
    return ContainerWidget(
      key: ValueKey(containers[index].id),  // Important!
      container: containers[index],
    );
  },
);
```

### 4. Debouncing Moves
```dart
Timer? _moveDebounce;

void onContainerTap(String id) {
  _moveDebounce?.cancel();
  _moveDebounce = Timer(Duration(milliseconds: 100), () {
    _processMove(id);
  });
}
```

---

## Common Patterns You'll Use

### 1. Command Pattern (Undo/Redo)
```dart
abstract class GameCommand {
  void execute();
  void undo();
}

class MoveCommand implements GameCommand {
  final Move move;
  final GameController controller;
  
  @override
  void execute() => controller.applyMove(move);
  
  @override
  void undo() => controller.applyMove(move.reverse());
}
```

### 2. Strategy Pattern (Themes)
```dart
class ThemeManager {
  GameTheme _currentTheme;
  
  void setTheme(ThemeType type) {
    _currentTheme = switch (type) {
      ThemeType.water => WaterTheme(),
      ThemeType.nutsBolts => NutsAndBoltsTheme(),
      ThemeType.balls => BallTheme(),
      ThemeType.testTubes => TestTubeTheme(),
    };
  }
  
  Widget buildForCurrentTheme(Container container) {
    return _currentTheme.buildContainer(container);
  }
}
```

### 3. Observer Pattern (Analytics)
```dart
class GameAnalytics {
  void trackEvent(GameEvent event) {
    switch (event) {
      case LevelStarted(:var levelId):
        _firebase.logEvent('level_start', {'level': levelId});
      case LevelCompleted(:var levelId, :var moves):
        _firebase.logEvent('level_complete', {
          'level': levelId,
          'moves': moves,
        });
    }
  }
}
```

---

## Testing Strategy

### Unit Tests (Game Logic)
```dart
test('Container.pourTo moves colors correctly', () {
  final from = Container(colors: [Red, Blue, Blue]);
  final to = Container.empty();
  
  final result = from.pourTo(to);
  
  expect(result.from.colors, [Red]);
  expect(result.to.colors, [Blue, Blue]);
});

test('MoveValidator prevents invalid moves', () {
  final from = Container(colors: [Red]);
  final to = Container(colors: [Blue], capacity: 3);
  
  expect(MoveValidator.canMove(from, to), false);
});
```

### Widget Tests (UI)
```dart
testWidgets('Tapping container selects it', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.byKey(Key('container-1')));
  await tester.pump();
  
  expect(find.byType(SelectedBorder), findsOneWidget);
});
```

---

## Debugging Tips

### 1. DevTools Timeline
- Record performance
- Look for jank (frames > 16ms)
- Check rebuild frequency

### 2. Print Game State
```dart
void debugPrintState() {
  print('=== Game State ===');
  for (var container in state.containers) {
    print('${container.id}: ${container.colors}');
  }
  print('Moves: ${state.moveCount}');
}
```

### 3. Visual Debug Overlays
```dart
if (kDebugMode) {
  return Stack(
    children: [
      gameBoard,
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(8),
          child: Text(
            'FPS: $currentFps\n'
            'Moves: ${state.moveCount}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ],
  );
}
```

---

## First Principles Reminder

**Game Loop Fundamentals:**
```
Input → Update → Render → Repeat (60 times/second)
```

**State Management:**
```
Old State + Event = New State (pure function)
Never mutate state directly
Always return new state instance
```

**Performance:**
```
Target: 16.67ms per frame (60 FPS)
Budget: ~10ms for logic, ~6ms for rendering
Anything expensive? Move to isolate or optimize
```

**User Experience:**
```
Feedback: Every action needs visual/audio response
Timing: Animations should feel natural (300-500ms)
Polish: Small details make huge difference
```

---

## Resources to Reference

**Flutter Game Dev:**
- Flame Engine docs (if we use it)
- Flutter performance best practices
- CustomPainter deep dive

**Puzzle Game Design:**
- Puzzle game difficulty curves
- Level generation algorithms
- Hint system design

**Mobile Performance:**
- Flutter DevTools guide
- Memory profiling
- Battery optimization

---

## Quick Wins Checklist (To Keep You Motivated)

Week 1:
- [ ] Project structure set up
- [ ] See colored containers on screen
- [ ] Click to select container
- [ ] Move validation working
- [ ] Undo button functional

Week 2:
- [ ] Pour animation working
- [ ] Sounds playing
- [ ] Win condition triggers
- [ ] Level transitions
- [ ] Feels like a game!

Week 3:
- [ ] Theme selector works
- [ ] Multiple themes visible
- [ ] Levels loading from JSON
- [ ] Progress saving
- [ ] Ready to show client!

---

## Remember

**You're building two things:**
1. A commercial product (deliver on time, within budget)
2. Your game development skills (learn deeply, understand why)

**Balance:**
- Don't over-engineer (it's a puzzle game, not a AAA title)
- Don't under-engineer (code must be maintainable)
- Perfect is the enemy of shipped

**When stuck:**
- Break it down smaller
- Get something visual working
- Test one piece at a time
- Ask "what's the simplest version?"

**Your strength:**
- Systems thinking (you understand databases, networks)
- First principles approach
- Backend architecture knowledge
- These translate directly to game architecture!

---

Now go paste that main prompt into Claude Code and start building! 🚀
