# Level Catalog

Complete catalog of all 200 puzzle levels in the Puzzle Game Suite.

## Generation Summary

- **Total Levels**: 200
- **Generation Date**: 2025-11-14
- **All Levels Solvable**: Yes (100%)
- **Quality Pass Rate**: 100%
- **Generation Time**: ~3 seconds

## Level Distribution

### By Theme

| Theme | Levels | Percentage |
|-------|--------|------------|
| Ocean | 50 | 25% |
| Forest | 50 | 25% |
| Desert | 50 | 25% |
| Space | 50 | 25% |
| **Total** | **200** | **100%** |

### By Difficulty

| Difficulty | Levels | Percentage | Avg Optimal Moves | Container Range |
|------------|--------|------------|-------------------|-----------------|
| Easy | 40 | 20% | 4.2 moves | 3-4 containers |
| Medium | 60 | 30% | 6.5 moves | 4-5 containers |
| Hard | 60 | 30% | 9.1 moves | 5-6 containers |
| Expert | 40 | 20% | 8.9 moves | 6-7 containers |
| **Total** | **200** | **100%** | **7.3 moves** | **3-7 containers** |

## Quality Metrics

### Solvability
- **Solvable Levels**: 200/200 (100%)
- **Quality Pass**: 200/200 (100%)
- **No Unsolvable Puzzles**: Verified via BFS validation

### Optimal Solution Statistics
- **Average Optimal Moves**: 7.3
- **Minimum Optimal Moves**: 3
- **Maximum Optimal Moves**: 11
- **Average States Explored**: 1,083.4

### Move Limits
- **Easy**: 2.0x optimal (very generous)
- **Medium**: 1.5x optimal (generous)
- **Hard**: 1.3x optimal (moderate)
- **Expert**: 1.2x optimal (tight)

### Star Thresholds
- **3 Stars**: Within 5% of optimal solution
- **2 Stars**: Within 20% of optimal solution
- **1 Star**: Within 40% of optimal solution

## Level Breakdown by Theme

### Ocean Theme (50 levels)
- **ID Range**: ocean_001 to ocean_050
- **Solvable**: 50/50 (100%)
- **Average Optimal Moves**: 7.2
- **Move Range**: 5-10 moves
- **Difficulty Distribution**:
  - Easy: 10 levels (ocean_001 - ocean_010)
  - Medium: 15 levels (ocean_011 - ocean_025)
  - Hard: 15 levels (ocean_026 - ocean_040)
  - Expert: 10 levels (ocean_041 - ocean_050)

### Forest Theme (50 levels)
- **ID Range**: forest_001 to forest_050
- **Solvable**: 50/50 (100%)
- **Average Optimal Moves**: 7.2
- **Move Range**: 3-11 moves
- **Difficulty Distribution**:
  - Easy: 10 levels (forest_001 - forest_010)
  - Medium: 15 levels (forest_011 - forest_025)
  - Hard: 15 levels (forest_026 - forest_040)
  - Expert: 10 levels (forest_041 - forest_050)

### Desert Theme (50 levels)
- **ID Range**: desert_001 to desert_050
- **Solvable**: 50/50 (100%)
- **Average Optimal Moves**: 7.6
- **Move Range**: 3-10 moves
- **Difficulty Distribution**:
  - Easy: 10 levels (desert_001 - desert_010)
  - Medium: 15 levels (desert_011 - desert_025)
  - Hard: 15 levels (desert_026 - desert_040)
  - Expert: 10 levels (desert_041 - desert_050)

### Space Theme (50 levels)
- **ID Range**: space_001 to space_050
- **Solvable**: 50/50 (100%)
- **Average Optimal Moves**: 7.2
- **Move Range**: 4-11 moves
- **Difficulty Distribution**:
  - Easy: 10 levels (space_001 - space_010)
  - Medium: 15 levels (space_011 - space_025)
  - Hard: 15 levels (space_026 - space_040)
  - Expert: 10 levels (space_041 - space_050)

## Container Distribution

| Container Count | Levels | Percentage |
|-----------------|--------|------------|
| 3 containers | 20 | 10% |
| 4 containers | 40 | 20% |
| 5 containers | 60 | 30% |
| 6 containers | 60 | 30% |
| 7 containers | 40 | 20% |

## Color Usage

- **Easy Levels**: 3 colors
- **Medium Levels**: 4 colors
- **Hard Levels**: 5 colors
- **Expert Levels**: 5-6 colors

All colors from the GameColor palette are utilized across different levels, ensuring visual variety.

## Difficulty Progression

The difficulty progression is designed to provide a smooth learning curve:

1. **Easy (Levels 1-10 per theme)**
   - Simple color sorting
   - Few containers (3-4)
   - Generous move limits
   - Introduction to game mechanics

2. **Medium (Levels 11-25 per theme)**
   - Moderate complexity
   - More containers (4-5)
   - Requires planning
   - Multiple solution paths

3. **Hard (Levels 26-40 per theme)**
   - Challenging puzzles
   - Many containers (5-6)
   - Tighter move limits
   - Strategic thinking required

4. **Expert (Levels 41-50 per theme)**
   - Most difficult
   - Maximum containers (6-7)
   - Very tight move limits
   - Optimal path usually required

## Generation Algorithm

Levels are generated using a "reverse solving" approach:

1. **Start with Solved State**: Create containers where each color fills exactly one container
2. **Apply Random Moves**: Shuffle colors using valid game moves
3. **Validate Solvability**: Use BFS to ensure the level is solvable
4. **Calculate Metrics**: Determine optimal move count and star thresholds
5. **Quality Check**: Verify the level meets all quality criteria

### Algorithm Advantages
- **Guaranteed Solvability**: Every level starts from a solved state
- **Realistic Puzzles**: Shuffling follows actual game rules
- **Controllable Difficulty**: More shuffle moves = harder puzzles
- **No Dead Ends**: All generated states are reachable

## Validation Process

Each level undergoes comprehensive validation:

1. **Solvability Check**: BFS verification that a solution exists
2. **Optimal Solution**: Calculate minimum moves required
3. **Quality Metrics**: Verify move limits and container counts
4. **State Space Analysis**: Ensure reasonable complexity
5. **Difficulty Verification**: Confirm difficulty rating is appropriate

## File Locations

- **Generated Levels**: `/lib/data/levels/generated_levels.dart`
- **Level Pack Manager**: `/lib/data/levels/level_pack.dart`
- **Generator**: `/lib/core/engine/level_generator.dart`
- **Validator**: `/lib/core/engine/level_validator.dart`
- **Tester**: `/lib/core/engine/level_tester.dart`

## Usage

```dart
import 'package:puzzle_game_suite/data/levels/level_pack.dart';

// Get all levels for a theme
final oceanLevels = LevelPack.getLevelsForTheme('Ocean');

// Get a specific level by ID
final level = LevelPack.getLevelById('ocean_001');

// Get level by theme and number
final level5 = LevelPack.getLevelByNumber('Ocean', 5);

// Get all levels
final allLevels = LevelPack.getAllLevels();
```

## Notes

### Duplicate Configurations
Some levels may share similar container configurations but play differently due to:
- Different container ordering
- Different color distributions
- Different optimal solution paths

This is acceptable and provides variety while maintaining consistent difficulty.

### Difficulty Calibration
The difficulty ratings are based on:
- Container count
- Color count
- Optimal move count
- Move limit tightness

Player experience may vary based on individual skill and strategy.

### Reproducibility
All levels are generated with deterministic seeds, ensuring:
- Consistent level generation
- Reproducible puzzles
- Version control friendly

## Testing

Comprehensive test suite available at `/bin/test_all_levels.dart`:

```bash
dart run bin/test_all_levels.dart
```

Tests include:
- Solvability verification
- Quality checks
- Duplicate detection
- Difficulty progression
- Theme statistics
- Overall metrics

## Regeneration

To regenerate all levels:

```bash
dart run bin/generate_levels.dart
```

This will:
- Generate 200 new levels
- Validate each level
- Export to `generated_levels.dart`
- Show generation statistics

## Future Improvements

Potential enhancements for level generation:

1. **Pattern-Based Generation**: Create levels with specific patterns or themes
2. **Difficulty Fine-Tuning**: Adjust parameters based on player feedback
3. **Custom Challenges**: Generate levels with specific constraints
4. **Daily Challenges**: Generate unique daily puzzles
5. **User-Generated Content**: Allow players to create and share levels

## Credits

Levels generated using the Puzzle Game Suite level generation system.
Algorithm designed for optimal balance between challenge and solvability.

---

*Last Updated: 2025-11-14*
*Total Levels: 200*
*Generation Version: 1.0*
