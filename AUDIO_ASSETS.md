# Audio Assets Documentation

This document describes the required audio assets for the puzzle game, including specifications, naming conventions, and recommendations.

## Directory Structure

```
assets/
└── sounds/
    ├── move.mp3
    ├── win_basic.mp3
    ├── win_good.mp3
    ├── win_perfect.mp3
    ├── error.mp3
    ├── undo.mp3
    ├── button_tap.mp3
    ├── level_start.mp3
    └── background.mp3
```

## Sound Effects (SFX)

### 1. move.mp3
**Purpose:** Played when user pours colors between containers

**Specifications:**
- **Duration:** 100-200ms
- **Character:** Satisfying "pour" or "splash" sound
- **Tone:** Positive, reward for action
- **Frequency:** 500-2000 Hz (mid-range, clear)
- **Volume:** Medium (not too loud)
- **Special:** System adds slight pitch randomization (0.95-1.05x) for variety

**Audio Design Tips:**
- Water pour sound
- Liquid splash
- Soft "glug" sound
- Should feel satisfying without being intrusive

---

### 2. win_basic.mp3
**Purpose:** Played when level completed with 1 star

**Specifications:**
- **Duration:** 500ms
- **Character:** Basic celebratory chime
- **Tone:** Pleasant, encouraging
- **Frequency:** Rising (500 → 1500 Hz)
- **Volume:** Slightly louder than normal SFX (1.2x multiplier)

**Audio Design Tips:**
- Single bell chime
- Simple success sound
- Positive reinforcement

---

### 3. win_good.mp3
**Purpose:** Played when level completed with 2 stars

**Specifications:**
- **Duration:** 700ms
- **Character:** Double chime, more celebratory
- **Tone:** Triumphant
- **Frequency:** Rising (500 → 2000 Hz)
- **Volume:** Slightly louder than normal SFX (1.2x multiplier)

**Audio Design Tips:**
- Two-note chime
- More elaborate than basic win
- Clear achievement feeling

---

### 4. win_perfect.mp3
**Purpose:** Played when level completed with 3 stars (perfect score)

**Specifications:**
- **Duration:** 1000ms
- **Character:** Full fanfare with flourish
- **Tone:** Very triumphant, exciting
- **Frequency:** Rising with harmonics (500 → 2000+ Hz)
- **Volume:** Slightly louder than normal SFX (1.2x multiplier)

**Audio Design Tips:**
- Three-note ascending fanfare
- Bells, chimes, sparkle sounds
- Dopamine-triggering reward sound
- Most elaborate of the three win sounds

---

### 5. error.mp3
**Purpose:** Played when invalid move is attempted

**Specifications:**
- **Duration:** 50-100ms (very short)
- **Character:** Gentle "no" signal
- **Tone:** Neutral, NOT harsh or punishing
- **Frequency:** Low (200-500 Hz, gentle)
- **Volume:** Quieter than positive sounds (0.7x multiplier)

**Audio Design Tips:**
- Soft "bonk" or "thud"
- Gentle decline in pitch
- Should communicate error WITHOUT frustration
- **AVOID:** Harsh buzzers, high-pitched sounds, long errors

**Philosophy:** Inform, don't punish. The sound should provide clear feedback without creating negative emotions.

---

### 6. undo.mp3
**Purpose:** Played when a move is undone

**Specifications:**
- **Duration:** 100-150ms
- **Character:** "Reverse" feel
- **Tone:** Neutral (not positive or negative)
- **Frequency:** Descending (800 → 400 Hz)
- **Volume:** Normal
- **Special:** System plays at 0.9x pitch for enhanced "reverse" feel

**Audio Design Tips:**
- Reverse of move sound (if possible)
- Descending pitch
- Quick "rewind" feel

---

### 7. button_tap.mp3
**Purpose:** Played when UI buttons are pressed

**Specifications:**
- **Duration:** 30-50ms (very short)
- **Character:** Subtle click
- **Tone:** Tactile feedback
- **Volume:** Reduced (0.5x multiplier) for subtle feedback

**Audio Design Tips:**
- Soft click sound
- Mechanical feedback
- Should feel like physical button press
- Very subtle, non-intrusive

---

### 8. level_start.mp3
**Purpose:** Played when level begins or resets

**Specifications:**
- **Duration:** 200-300ms
- **Character:** Energetic, ready-to-go
- **Tone:** Signals beginning, motivating
- **Frequency:** Rising or stable mid-range

**Audio Design Tips:**
- Upward chime
- "Ready, set, go" feeling
- Energetic without being jarring

---

## Background Music

### 9. background.mp3
**Purpose:** Looping background music during gameplay

**Specifications:**
- **Duration:** 60-180 seconds (1-3 minutes recommended)
- **Character:** Calm, focused, pleasant
- **Tempo:** Moderate (90-120 BPM)
- **Mood:** Ambient, non-intrusive
- **Style:** Instrumental puzzle music
- **Volume:** Lower than SFX (0.6x default multiplier)
- **Special:** Must loop seamlessly, 1-second fade in/out

**Audio Design Tips:**
- Instrumental only (no vocals)
- Ambient, calming
- Should not distract from gameplay
- Think: puzzle game music, lo-fi, ambient
- Examples: Monument Valley, Flow, Journey

**Looping Requirements:**
- First and last 500ms should be similar for seamless loop
- No abrupt endings
- Fade-compatible (for pause/resume)

---

## File Format Specifications

### Required Format
- **Format:** MP3 (widely compatible)
- **Sample Rate:** 44.1 kHz (standard CD quality)
- **Bit Rate:** 128 kbps (good balance of quality/size)
- **Channels:** Stereo (for music), Mono acceptable (for SFX)

### Alternative Formats (Optional)
- **OGG:** Better compression, good for Android
- **AAC/M4A:** Good for iOS
- **Note:** MP3 is recommended for cross-platform compatibility

### File Size Guidelines
- **SFX:** 10-50 KB each (short sounds)
- **Background Music:** 1-3 MB (longer loops)
- **Total Audio:** Keep under 5 MB for mobile optimization

---

## Audio Normalization

### Volume Standards
All audio files should be normalized to prevent volume inconsistencies:

- **SFX Peak:** -3 dB to 0 dB
- **Music Peak:** -6 dB to -3 dB (quieter than SFX)
- **Error Sounds:** -9 dB to -6 dB (quietest)

### Recommended Tools
- **Audacity:** Free, cross-platform audio editor
- **Adobe Audition:** Professional audio editing
- **GarageBand:** Mac/iOS audio creation
- **LMMS:** Free music production
- **Online Tools:** Audio Trimmer, MP3Cut

---

## Naming Conventions

### Rules
1. Use lowercase letters only
2. Use underscores for spaces
3. Use `.mp3` extension
4. Be descriptive and consistent

### Examples
- **Good:** `move.mp3`, `win_perfect.mp3`, `button_tap.mp3`
- **Bad:** `Move.MP3`, `Win-Perfect.mp3`, `btn_tap.wav`

---

## Free Audio Resources

### Sound Effects
- **Freesound.org** - Community-uploaded sounds (various licenses)
- **OpenGameArt.org** - Game-focused assets (open source)
- **Zapsplat.com** - Large library (free with attribution)
- **Sonniss.com** - Annual free GDC bundles
- **JSFXR** - Generate simple game sounds online

### Music
- **Incompetech.com** - Royalty-free music by Kevin MacLeod
- **FreeMusicArchive.org** - Various genres and licenses
- **Purple Planet** - Free music for games
- **Bensound.com** - Royalty-free music
- **YouTube Audio Library** - Free music and sound effects

### Important Notes
- Always check licenses before using
- Some require attribution (credit the creator)
- Some restrict commercial use
- Keep track of sources for legal compliance

---

## Testing Without Audio Files

The audio system is designed to work gracefully without audio files:

1. **No Crashes:** Missing files won't crash the app
2. **Silent Mode:** Game continues to function normally
3. **Development:** You can develop and test without audio
4. **Logging:** Console shows which files are missing

### Error Handling
```dart
// Audio service fails gracefully
audioService.playMove(); // Won't crash if move.mp3 is missing
```

---

## Platform Considerations

### iOS
- Uses `AVAudioPlayer` internally
- Respects silent mode (device mute switch)
- Good low-latency performance
- Supports background audio (for music)

### Android
- Uses `MediaPlayer` internally
- Separate volume streams (game, music, notification)
- Audio focus handling (pauses when phone call)
- Good compatibility across devices

### Web
- Uses HTML5 Audio
- Autoplay restrictions may apply
- Some browsers limit simultaneous sounds
- Latency may be higher than native

### Desktop
- Platform-specific audio backends
- Generally good performance
- May have different audio routing

---

## Performance Optimization

### Preloading Strategy
The following sounds are preloaded for instant playback:
1. move.mp3 (most frequent)
2. All win sounds (3 variations)
3. error.mp3
4. undo.mp3
5. button_tap.mp3
6. level_start.mp3

### Memory Management
- Sound pooling prevents memory bloat
- Idle players returned to pool after 30 seconds
- Background music uses separate player
- Cache cleared when memory constrained

### Latency Reduction
- SFX use low-latency mode
- Music uses media player mode
- Preloading eliminates file load time
- Object pooling prevents initialization delay

---

## Audio Psychology

### Positive Reinforcement
- **Move sounds:** Satisfying, encourage action
- **Win sounds:** Celebratory, dopamine trigger
- **Level start:** Energizing, motivating

### Error Handling
- **Error sounds:** Gentle, informative not punishing
- **Principle:** Clear feedback without frustration
- **Volume:** Quieter than positive sounds

### Immersion
- **Background music:** Sets mood, maintains focus
- **Consistent theme:** All sounds fit together
- **Volume hierarchy:** Music doesn't compete with SFX

---

## Volume Hierarchy

System automatically applies volume multipliers:

```
Master Volume (user controlled)
├─ SFX Volume (user controlled)
│  ├─ Move: 1.0x
│  ├─ Win: 1.2x (emphasis)
│  ├─ Error: 0.7x (softer)
│  ├─ Undo: 1.0x
│  ├─ Button: 0.5x (subtle)
│  └─ Level Start: 1.0x
└─ Music Volume (user controlled)
   └─ Background: 1.0x (default 0.6)
```

---

## Accessibility

### Visual Alternatives
- All audio has visual equivalents
- Game fully playable without sound
- Screen reader support
- Haptic feedback complements audio

### User Control
- Master volume control
- Separate SFX/Music toggles
- Settings persistence
- Respects system mute

---

## Integration Status

### Implemented
- Audio service with full API
- Audio manager with pooling
- Volume controls
- Settings persistence
- Platform-specific handling
- Graceful error handling
- Integration with game controller
- Integration with UI controls
- Haptic feedback support

### Ready for Assets
The system is fully functional and ready to use once you add audio files to `assets/sounds/`. Simply drop in the MP3 files and they'll work automatically.

---

## Quick Start Checklist

1. [ ] Create placeholder sounds (or download from free resources)
2. [ ] Place files in `assets/sounds/` directory
3. [ ] Verify file names match exactly (case-sensitive)
4. [ ] Test on device (not just simulator)
5. [ ] Adjust volumes if needed (in audio_service.dart)
6. [ ] Test with headphones and speakers
7. [ ] Test all game scenarios (win, loss, errors)
8. [ ] Get user feedback on sound design

---

## Support & Questions

For audio implementation questions:
- Check code comments in `audio_service.dart`
- Check code comments in `audio_manager.dart`
- Reference this documentation
- Test with sample files first

---

**Note:** This audio system is production-ready and fully documented. The only missing piece is the actual audio files, which you can create, download, or commission based on your needs and budget.
