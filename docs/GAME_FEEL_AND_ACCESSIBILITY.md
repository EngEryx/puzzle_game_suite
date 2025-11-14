# Game Feel & Accessibility Guide

## Introduction

This document provides comprehensive guidelines for game feel, feedback systems, and accessibility considerations in the puzzle game.

## Game Feel Principles

### What is "Game Feel"?

Game feel (or "game juice") refers to the tactile, visual, and audio feedback that makes a game satisfying to play. It's the difference between a functional game and a delightful one.

### Core Principles

1. **Immediate Feedback:** Every action gets instant response
2. **Appropriate Intensity:** Feedback matches action importance
3. **Layered Feedback:** Multiple channels (visual + audio + haptic)
4. **Consistency:** Similar actions get similar feedback
5. **Rewards Over Punishment:** Celebrate success more than punishing failure

## Feedback Systems

### Visual Feedback

#### Button Presses
```dart
// Scale animation on press
Transform.scale(
  scale: 0.95,  // Subtle feedback
  child: button,
)
```

**Why it works:**
- Physical metaphor (button depresses)
- Immediate confirmation
- Doesn't interfere with gameplay

#### State Changes
```dart
// Disabled state
Opacity(
  opacity: enabled ? 1.0 : 0.4,  // Clear visual distinction
  child: widget,
)
```

**Why it works:**
- Clearly communicates availability
- Prevents confusion
- Maintains visual hierarchy

#### Celebrations (Win State)
```dart
// Multi-layered celebration
- Trophy icon (achievement)
- Gradient background (positive atmosphere)
- Star animation (variable reward)
- Encouraging message (positive reinforcement)
- Entry animation (attention grabbing)
```

**Why it works:**
- Multiple reward signals
- Builds excitement
- Creates memorable moment
- Motivates continuation

### Audio Feedback

#### Sound Hierarchy

| Action | Intensity | Frequency | Duration | Purpose |
|--------|-----------|-----------|----------|---------|
| Error | Low | 200-500 Hz | 50-100ms | Inform without punishing |
| Move | Medium | 500-2000 Hz | 100-200ms | Confirm action |
| Win | High | Rising | 500-1000ms | Celebrate achievement |

#### Audio Psychology

**Positive Sounds (Move, Win):**
- Higher pitch = more positive
- Rising pitch = excitement
- Longer duration = more important
- Brighter timbre = more celebratory

**Negative Sounds (Error):**
- Lower pitch = less harsh
- Shorter duration = less annoying
- Softer volume = less punishing
- Neutral timbre = informative, not judgmental

**Background Music:**
- Ambient, non-intrusive
- Moderate tempo (60-100 BPM)
- Minor keys or modal (contemplative)
- Seamless looping
- Lower volume than SFX

### Haptic Feedback

#### Intensity Levels

```dart
// Light impact - most common
HapticFeedback.lightImpact()

// Medium impact - important actions
HapticFeedback.mediumImpact()

// Heavy impact - rare, significant events
HapticFeedback.heavyImpact()

// Selection - UI navigation
HapticFeedback.selectionClick()
```

#### Usage Guidelines

| Action | Haptic Type | When |
|--------|-------------|------|
| Button press | Selection | Always |
| Valid move | Light | On success |
| Undo | Light | On success |
| Reset | Medium | After confirmation |
| Win | Heavy + pattern | On level complete |
| Error | None or vibrate | Invalid action |

**Best Practices:**
- Don't overuse (fatigue)
- Match intensity to importance
- Test on real devices
- Respect system settings
- Provide toggle option

### Animation Principles

#### Timing

```dart
// Quick feedback (buttons)
Duration(milliseconds: 100-150)

// Standard transitions (dialogs)
Duration(milliseconds: 300-400)

// Celebrations (wins)
Duration(milliseconds: 800-1200)
```

**Rule of thumb:** Faster = more responsive, Slower = more dramatic

#### Easing Curves

```dart
// Natural motion (most common)
Curves.easeInOut

// Snappy (buttons, quick actions)
Curves.easeOut

// Dramatic entrance
Curves.easeOutCubic

// Bouncy feel (celebrations)
Curves.elasticOut
```

#### Staggering

```dart
// Stars appearing one at a time
for (int i = 0; i < stars; i++) {
  Future.delayed(Duration(milliseconds: i * 100), () {
    showStar(i);
  });
}
```

**Why it works:**
- Creates anticipation
- Draws attention
- Feels more organic
- More satisfying reveal

## Accessibility

### Visual Accessibility

#### Color Contrast

**WCAG 2.1 Guidelines:**
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum
- UI components: 3:1 minimum

**Implementation:**
```dart
// Good contrast
Text(
  'Level Complete',
  style: TextStyle(
    color: Colors.grey[900],  // Dark on light
    backgroundColor: Colors.white,
  ),
)

// Check contrast ratios
// Tool: WebAIM Contrast Checker
```

#### Color Independence

**Problem:** Color-only information excludes color-blind users (8% of males)

**Solution:** Multiple indicators
```dart
// Bad: Only color indicates disabled
Container(color: isEnabled ? Colors.blue : Colors.grey)

// Good: Color + opacity + icon
Opacity(
  opacity: isEnabled ? 1.0 : 0.4,
  child: Icon(
    isEnabled ? Icons.check : Icons.block,
    color: isEnabled ? Colors.blue : Colors.grey,
  ),
)
```

#### Text Sizing

```dart
// Use relative sizes
Text(
  'Button',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Users can scale in system settings
// App respects MediaQuery.textScaleFactor
```

**Guidelines:**
- Minimum: 12pt (16sp)
- Body text: 14-16pt
- Headers: 18-24pt
- Touch labels: 14pt minimum

### Touch Accessibility

#### Touch Target Size

**iOS Guidelines:** 44x44 points
**Android Guidelines:** 48x48 dp
**Our Standard:** 48x48 logical pixels

```dart
// Always ensure minimum size
Container(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.undo),
    onPressed: onUndo,
  ),
)
```

#### Touch Target Spacing

**Minimum spacing between targets:** 8 logical pixels

```dart
Row(
  children: [
    button1,
    SizedBox(width: 8),  // Minimum spacing
    button2,
  ],
)
```

**Why:** Prevents accidental taps, especially for users with motor impairments

### Screen Reader Support

#### Semantic Labels

```dart
// Good: Clear semantic meaning
Semantics(
  label: 'Undo last move',
  button: true,
  enabled: canUndo,
  child: IconButton(
    icon: Icon(Icons.undo),
    onPressed: canUndo ? onUndo : null,
  ),
)

// Star rating example
Semantics(
  label: '3 out of 5 stars',
  child: StarRating(stars: 3, totalStars: 5),
)
```

#### Focus Order

```dart
// Ensure logical tab order
Semantics(
  sortKey: OrdinalSortKey(1.0),  // First
  child: widget1,
)
Semantics(
  sortKey: OrdinalSortKey(2.0),  // Second
  child: widget2,
)
```

#### Announcements

```dart
// Announce important changes
SemanticsService.announce(
  'Level complete!',
  TextDirection.ltr,
);
```

### Keyboard Navigation

#### Support (Desktop/Web)

```dart
// Focus node for keyboard control
final focusNode = FocusNode();

// Keyboard shortcuts
KeyboardListener(
  focusNode: focusNode,
  onKeyEvent: (event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyZ &&
          event.isControlPressed) {
        controller.undo();
      }
    }
  },
  child: widget,
)
```

**Common Shortcuts:**
- Ctrl/Cmd + Z: Undo
- Ctrl/Cmd + R: Reset
- H: Hint
- Arrow keys: Navigate
- Enter: Select
- Escape: Cancel/Back

### Reduced Motion

#### System Setting

```dart
// Detect reduced motion preference
final disableAnimations = MediaQuery.of(context)
    .disableAnimations;

// Adapt animations
AnimationController(
  duration: disableAnimations
      ? Duration.zero  // Skip animation
      : Duration(milliseconds: 400),
  vsync: this,
)
```

#### Alternative Feedback

When animations disabled:
- Still show end result
- Use instant state changes
- Keep audio/haptic (if enabled)
- Maintain functionality

### Audio Accessibility

#### Visual Alternatives

**Never rely solely on audio for information**

```dart
// Bad: Only sound indicates error
audio.playError();

// Good: Sound + visual message
audio.playError();
showErrorSnackBar('Invalid move');
```

#### Captions/Subtitles

For narrative audio (if added):
- Provide text alternatives
- Show important sound cues
- Indicate speaker/source

#### Volume Control

```dart
// Always provide controls
- Master volume
- SFX volume (separate)
- Music volume (separate)
- Mute toggles
```

## Testing Checklist

### Visual Testing

- [ ] Test with high contrast mode
- [ ] Test with inverted colors
- [ ] Test with color blindness simulator
- [ ] Test at 200% text size
- [ ] Test in bright sunlight
- [ ] Test in dark environment

### Touch Testing

- [ ] Test with large fingers
- [ ] Test with stylus
- [ ] Test with one hand
- [ ] Test while moving
- [ ] Test with gloves (if applicable)

### Audio Testing

- [ ] Test without sound (muted device)
- [ ] Test with headphones
- [ ] Test in noisy environment
- [ ] Test at different volumes
- [ ] Test with hearing aids (if possible)

### Screen Reader Testing

- [ ] Test with VoiceOver (iOS)
- [ ] Test with TalkBack (Android)
- [ ] Test with NVDA/JAWS (Web)
- [ ] Verify all buttons labeled
- [ ] Verify logical focus order
- [ ] Verify announcements work

### Keyboard Testing

- [ ] Test all actions with keyboard
- [ ] Test tab order
- [ ] Test keyboard shortcuts
- [ ] Verify focus indicators visible
- [ ] Test Escape key behavior

### Motor Testing

- [ ] Test with one hand
- [ ] Test with stylus
- [ ] Test with switch control
- [ ] Test with voice control
- [ ] Time limit: none (puzzle game)

## Implementation Priorities

### Phase 1 (Week 1) ✓
- [x] Visual feedback (button presses)
- [x] State-aware UI (disabled states)
- [x] Touch target sizes (48x48)
- [x] Semantic labels
- [x] High contrast colors
- [x] Clear visual hierarchy

### Phase 2 (Week 2)
- [ ] Audio implementation
- [ ] Haptic feedback
- [ ] Animation polish
- [ ] Volume controls
- [ ] Settings persistence

### Phase 3 (Week 3+)
- [ ] Keyboard shortcuts
- [ ] Reduced motion support
- [ ] Advanced screen reader features
- [ ] Accessibility settings panel
- [ ] User testing with disabled users

## Resources

### Testing Tools

**Color/Contrast:**
- WebAIM Contrast Checker
- Stark (Figma plugin)
- Color Oracle (color blindness simulator)

**Screen Readers:**
- iOS: VoiceOver (built-in)
- Android: TalkBack (built-in)
- Web: NVDA (free), JAWS

**Accessibility Audits:**
- Flutter's `debugDumpSemanticsTree()`
- Accessibility Inspector (Xcode)
- Android Accessibility Scanner
- axe DevTools (web)

### Guidelines

**Standards:**
- WCAG 2.1 (Web Content Accessibility Guidelines)
- Apple Human Interface Guidelines
- Material Design Accessibility
- Game Accessibility Guidelines

**Resources:**
- AbleGamers.org
- GameAccessibilityGuidelines.com
- A11y Project
- Microsoft Inclusive Design

## Conclusion

Great game feel and accessibility are not mutually exclusive. In fact, many accessibility features improve the experience for everyone:

- **Clear feedback:** Benefits all users
- **Multiple channels:** Reaches more users
- **Customization:** Personal preference for all
- **Keyboard support:** Faster for power users
- **High contrast:** Better in all conditions

By following these guidelines, we create a game that's:
1. **Delightful** to play
2. **Accessible** to more people
3. **Professional** in quality
4. **Inclusive** by design

Remember: **Accessibility is not a feature, it's a fundamental requirement.**
