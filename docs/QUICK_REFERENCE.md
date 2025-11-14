# Quick Reference Guide - Game Controls

## File Locations

```
lib/
├── features/game/presentation/widgets/
│   ├── game_controls.dart       # Control bar (Undo, Reset, Hint)
│   └── win_dialog.dart          # Victory celebration dialog
├── shared/widgets/
│   └── star_rating.dart         # Reusable star rating widget
└── core/services/
    └── audio_service.dart       # Audio management (placeholder)

docs/
├── GAME_POLISH.md                    # Comprehensive polish guide
├── GAME_FEEL_AND_ACCESSIBILITY.md    # Game feel & a11y guide
└── QUICK_REFERENCE.md                # This file
```

## Quick Usage

### Game Controls

```dart
import 'package:puzzle_game_suite/features/game/presentation/widgets/game_controls.dart';

// Add to bottom of game screen
Scaffold(
  body: Column(
    children: [
      Expanded(child: GameBoard()),
      GameControls(), // <- Add here
    ],
  ),
)
```

### Win Dialog

```dart
import 'package:puzzle_game_suite/features/game/presentation/widgets/win_dialog.dart';

// Show when game is won
if (gameState.isWon) {
  await WinDialog.show(context);
}

// Or use listener
ref.listen(isWonProvider, (previous, next) {
  if (next) WinDialog.show(context);
});
```

### Star Rating

```dart
import 'package:puzzle_game_suite/shared/widgets/star_rating.dart';

// Small (lists)
StarRating.small(stars: 2)

// Medium (cards)
StarRating.medium(stars: 3)

// Large (dialogs)
StarRating.large(stars: 1)

// With animation
StarRating(
  stars: 3,
  totalStars: 3,
  animationController: _controller,
)

// Custom
StarRating(
  stars: 2,
  totalStars: 5,
  size: 32,
  filledColor: Colors.orange,
)
```

### Audio Service

```dart
import 'package:puzzle_game_suite/core/services/audio_service.dart';

// Get service
final audio = ref.read(audioServiceProvider);

// Play sounds (placeholders for now)
audio.playMove();           // On valid move
audio.playWin(stars: 3);    // On level complete
audio.playError();          // On invalid action
audio.playUndo();           // On undo
audio.playButtonTap();      // On UI interaction

// Control settings
audio.setSfxEnabled(false);
audio.setMusicEnabled(true);
audio.setMasterVolume(0.8);
```

## Key Components

### GameControls Buttons

| Button | Icon | Enabled | Action |
|--------|------|---------|--------|
| Undo | undo | When `canUndo` | Reverse last move |
| Reset | refresh | Always | Reset puzzle (with confirm) |
| Hint | lightbulb_outline | Disabled | Show hint (Week 2) |

### WinDialog Actions

| Button | Type | Action |
|--------|------|--------|
| Next Level | FilledButton | Load next level (placeholder) |
| Replay | OutlinedButton | Reset current level |
| Home | OutlinedButton | Return to home screen |

### Star Rating Sizes

| Preset | Size | Spacing | Use Case |
|--------|------|---------|----------|
| Small | 16px | 2px | Lists, compact layouts |
| Medium | 24px | 4px | Cards, inline |
| Large | 48px | 8px | Dialogs, celebrations |

## State Providers

```dart
// Game state
final gameState = ref.watch(gameProvider);
final controller = ref.read(gameProvider.notifier);

// Derived states
final canUndo = ref.watch(canUndoProvider);
final isWon = ref.watch(isWonProvider);
final isGameOver = ref.watch(isGameOverProvider);
final moveCount = ref.watch(moveCountProvider);
final stars = ref.watch(currentStarsProvider);

// Services
final audio = ref.read(audioServiceProvider);
```

## Common Patterns

### Show Confirmation Dialog

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Reset Puzzle?'),
    content: Text('All progress will be lost.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          controller.reset();
          Navigator.pop(context);
        },
        child: Text('Reset'),
      ),
    ],
  ),
);
```

### Show SnackBar Feedback

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Move undone'),
    duration: Duration(milliseconds: 800),
    behavior: SnackBarBehavior.floating,
  ),
);
```

### Error Handling

```dart
try {
  controller.makeMove(fromId, toId);
  audio.playMove();
} catch (e) {
  audio.playError();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Invalid move: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Animation Values

### Durations

```dart
// Button press
Duration(milliseconds: 100)

// Dialog entry
Duration(milliseconds: 400)

// Star animation
Duration(milliseconds: 400) // per star
Duration(milliseconds: 100) // stagger delay
```

### Transforms

```dart
// Button scale
scale: 0.95  // Pressed state

// Opacity
opacity: 0.4  // Disabled state
opacity: 1.0  // Enabled state
```

## Accessibility

### Touch Targets

```dart
// Minimum size
Container(width: 48, height: 48, ...)

// Minimum spacing
SizedBox(width: 8)
```

### Semantic Labels

```dart
Semantics(
  label: 'Undo last move',
  button: true,
  enabled: canUndo,
  child: button,
)
```

### Tooltips

```dart
Tooltip(
  message: 'Undo last move',
  child: IconButton(...),
)
```

## Week 2 TODO

### Audio Implementation

1. Add package: `audioplayers: ^6.0.0`
2. Add assets in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/sounds/
       - assets/music/
   ```
3. Implement `AudioService` methods
4. Add sound files (see GAME_POLISH.md)

### Haptic Feedback

1. Add `HapticFeedback.lightImpact()` in controls
2. Test on real devices
3. Add settings toggle

### Tests

```dart
testWidgets('Undo button disabled when no moves', (tester) async {
  // Test implementation
});

testWidgets('Win dialog shows on completion', (tester) async {
  // Test implementation
});
```

## Troubleshooting

### Buttons Not Responding

Check:
1. Provider is properly watched: `ref.watch(canUndoProvider)`
2. Controller is accessed: `ref.read(gameProvider.notifier)`
3. Scaffold is ancestor (for SnackBars)

### Animations Not Working

Check:
1. `SingleTickerProviderStateMixin` added
2. Controller initialized in `initState`
3. Controller disposed in `dispose`
4. Widget is stateful (not stateless)

### Dialog Not Showing

Check:
1. Context is valid
2. No other dialog already shown
3. `await WinDialog.show(context)` is called
4. Scaffold exists in tree

## Testing Checklist

- [ ] Undo disabled with no moves
- [ ] Undo enabled after move
- [ ] Reset shows confirmation
- [ ] Reset actually resets
- [ ] Win dialog appears on win
- [ ] Stars display correctly
- [ ] All buttons have feedback
- [ ] Touch targets at least 48x48
- [ ] Tooltips appear on long press
- [ ] Screen reader labels present

## Performance Tips

1. Use `const` constructors when possible
2. Keep animation durations < 400ms
3. Dispose controllers properly
4. Use derived providers for computed values
5. Avoid rebuilding entire tree

## Common Mistakes

❌ **Don't:**
```dart
// Accessing controller in watch
final controller = ref.watch(gameProvider.notifier);

// Not disposing animation controllers
// Animation controller leak!

// Showing dialog without checking state
WinDialog.show(context); // Always shows!
```

✅ **Do:**
```dart
// Watch for state, read for actions
final canUndo = ref.watch(canUndoProvider);
final controller = ref.read(gameProvider.notifier);

// Always dispose
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Check state before showing
if (gameState.isWon) {
  WinDialog.show(context);
}
```

## Resources

- **Code:** `lib/features/game/presentation/widgets/`
- **Docs:** `docs/GAME_POLISH.md`
- **Examples:** In-file documentation
- **Flutter Docs:** flutter.dev/docs
- **Riverpod Docs:** riverpod.dev

## Support

For questions or issues:
1. Check inline documentation (extensive)
2. See `GAME_POLISH.md` for details
3. See `GAME_FEEL_AND_ACCESSIBILITY.md` for principles
4. Review usage examples in file comments

---

**Last Updated:** Week 1 - Controls, Dialog, Stars, Audio Structure
**Next Update:** Week 2 - Audio Implementation, Haptic, Tests
