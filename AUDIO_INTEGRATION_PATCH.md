# Audio Integration Patch for game_controller.dart

This file contains the manual changes needed to integrate audio into the game controller.

## Changes Required

### 1. Add import at the top (after line 7)
```dart
import '../../../core/services/audio_service.dart';
```

### 2. Add audio service field to GameController class (after line 101, before _currentAnimation)
```dart
  /// Audio service for sound effects
  final AudioService? _audioService;
```

### 3. Update constructor (replace line 115)

**OLD:**
```dart
  GameController(Level level) : super(GameState.fromLevel(level));
```

**NEW:**
```dart
  GameController(Level level, {AudioService? audioService})
      : _audioService = audioService,
        super(GameState.fromLevel(level));
```

### 4. Add audio to makeMove method (after line 157, after `state = newState;`)
```dart
      // Play move sound
      _audioService?.playMove();
```

### 5. Add error sound to makeMove catch block (after line 169, at start of catch block)
```dart
      // Play error sound for invalid move
      _audioService?.playError();
```

### 6. Add undo sound to undo method (after line 198, after `state = newState;`)
```dart
      // Play undo sound
      _audioService?.playUndo();
```

### 7. Add sound to reset method (after line 218, after `state = newState;`)
```dart
      // Play level start sound
      _audioService?.playLevelStart();
```

### 8. Add sound to loadLevel method (after line 232, after `state = GameState.fromLevel(level);`)
```dart
      // Play level start sound
      _audioService?.playLevelStart();
```

### 9. Update _onGameWon method (replace lines 322-332)

**OLD:**
```dart
  void _onGameWon() {
    // Could trigger:
    // - Victory animation
    // - Sound effect
    // - Achievement unlock
    // - Stats save
    // - Show next level button

    // final stars = state.currentStars;
    // print('🎉 Won! Stars: $stars, Moves: ${state.moveCount}');
  }
```

**NEW:**
```dart
  void _onGameWon() {
    // Could trigger:
    // - Victory animation
    // - Sound effect
    // - Achievement unlock
    // - Stats save
    // - Show next level button

    final stars = state.currentStars;

    // Play win sound with appropriate star level
    _audioService?.playWin(stars: stars);

    // print('🎉 Won! Stars: $stars, Moves: ${state.moveCount}');
  }
```

### 10. Update _onGameLost method (replace lines 334-342)

**OLD:**
```dart
  void _onGameLost() {
    // Could trigger:
    // - Failure animation
    // - Encouraging message
    // - Hint offer
    // - Retry button

    // print('😢 Lost! Move limit: ${state.level.moveLimit}');
  }
```

**NEW:**
```dart
  void _onGameLost() {
    // Could trigger:
    // - Failure animation
    // - Encouraging message
    // - Hint offer
    // - Retry button

    // Play error sound (gentle, not punishing)
    _audioService?.playError();

    // print('😢 Lost! Move limit: ${state.level.moveLimit}');
  }
```

### 11. Update gameProvider (replace lines 386-392)

**OLD:**
```dart
final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  // Get current level (dependency)
  final level = ref.watch(currentLevelProvider);

  // Create controller with level
  return GameController(level);
});
```

**NEW:**
```dart
final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  // Get current level (dependency)
  final level = ref.watch(currentLevelProvider);

  // Get audio service (dependency)
  final audioService = ref.watch(audioServiceProvider);

  // Create controller with level and audio service
  return GameController(level, audioService: audioService);
});
```

## Notes

- All audio calls use null-safe operator (`?.`) so audio is optional
- Game works perfectly fine without audio service
- Audio plays automatically on game actions
- No additional UI changes needed beyond what's already in game_controls.dart

## Verification

After making these changes, you should hear:
- Move sound when pouring colors
- Error sound on invalid moves
- Undo sound when undoing
- Level start sound when starting/resetting
- Win sound (1/2/3 stars) when completing level
- Error sound when losing (move limit exceeded)

## Alternative: Automatic Application

If you prefer, you can apply these changes by copying the backup file and manually editing it, or wait for the linter to finish and reapply the Edit tool commands.
