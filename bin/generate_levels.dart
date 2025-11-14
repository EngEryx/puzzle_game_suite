import 'dart:io';
import 'dart:convert';
import 'package:puzzle_game_suite/core/models/level.dart';
import 'package:puzzle_game_suite/core/engine/level_generator.dart';

/// Command-line tool to generate all 200 levels.
///
/// USAGE:
///
/// ```bash
/// dart run bin/generate_levels.dart
/// ```
///
/// This will:
/// 1. Generate 200 levels (50 per theme, 4 themes)
/// 2. Validate each level is solvable
/// 3. Export to lib/data/levels/generated_levels.dart
/// 4. Show progress during generation
///
/// OUTPUT FILE:
///
/// The generated file contains Dart constants with all levels,
/// organized by theme for easy loading at runtime.
///
/// GENERATION TIME:
///
/// Expected: 2-5 minutes for all 200 levels
/// - Each level takes ~0.5-2 seconds to generate and validate
/// - Progress bar shows current status
/// - Failures are retried automatically
///
/// REPRODUCIBILITY:
///
/// The generator uses deterministic seeds based on theme and level number,
/// so running this script multiple times will produce the same levels.
/// To generate new variations, modify the seed algorithm in level_generator.dart.

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║           Puzzle Game Suite - Level Generator             ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  // Themes
  final themes = ['Ocean', 'Forest', 'Desert', 'Space'];
  const levelsPerTheme = 50;

  // Track stats
  final startTime = DateTime.now();
  int totalGenerated = 0;
  int totalFailed = 0;

  // Storage for all levels
  final allLevels = <String, List<Level>>{};

  // Generate levels for each theme (with retries)
  for (final theme in themes) {
    print('┌─────────────────────────────────────────────────────────┐');
    print('│ Theme: ${theme.padRight(48)}│');
    print('└─────────────────────────────────────────────────────────┘');
    print('');

    bool success = false;
    int themeAttempt = 0;
    const maxThemeAttempts = 3;

    while (!success && themeAttempt < maxThemeAttempts) {
      themeAttempt++;

      if (themeAttempt > 1) {
        print('Retry attempt $themeAttempt...');
        print('');
      }

      try {
        final themeLevels = LevelGenerator.generateLevelPack(
          themes: [theme],
          levelsPerTheme: levelsPerTheme,
          onProgress: (currentTheme, current, total) {
            _showProgress(current, total);
          },
        );

        allLevels[theme] = themeLevels[theme]!;
        totalGenerated += themeLevels[theme]!.length;

        print('\n✓ Generated ${themeLevels[theme]!.length} levels for $theme');
        print('');
        success = true;
      } catch (e) {
        if (themeAttempt >= maxThemeAttempts) {
          print('\n✗ Failed to generate levels for $theme after $maxThemeAttempts attempts: $e');
          totalFailed += levelsPerTheme;
          print('');
        } else {
          print('\n⚠ Attempt $themeAttempt failed, retrying...');
          print('');
        }
      }
    }
  }

  // Summary
  print('┌─────────────────────────────────────────────────────────┐');
  print('│ Generation Summary                                      │');
  print('└─────────────────────────────────────────────────────────┘');
  print('');
  print('Total levels generated: $totalGenerated');
  print('Failed: $totalFailed');
  print('Time elapsed: ${DateTime.now().difference(startTime).inSeconds}s');
  print('');

  // Export to Dart file
  if (totalGenerated > 0) {
    print('Exporting levels to generated_levels.dart...');

    final outputPath = 'lib/data/levels/generated_levels.dart';
    final dartCode = _generateDartCode(allLevels);

    try {
      final file = File(outputPath);
      await file.writeAsString(dartCode);
      print('✓ Levels exported successfully!');
      print('  File: $outputPath');
      print('  Size: ${(dartCode.length / 1024).toStringAsFixed(2)} KB');
    } catch (e) {
      print('✗ Failed to export levels: $e');
      exit(1);
    }
  }

  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║                    Generation Complete!                   ║');
  print('╚════════════════════════════════════════════════════════════╝');
}

/// Show progress bar.
void _showProgress(int current, int total) {
  const barWidth = 40;
  final percentage = (current / total * 100).round();
  final filled = (current / total * barWidth).round();
  final empty = barWidth - filled;

  final bar = '█' * filled + '░' * empty;
  final label = 'Level ${current.toString().padLeft(2)}/$total';

  // Use \r to overwrite line
  stdout.write('\r[$bar] $percentage% $label');
}

/// Generate Dart code for all levels.
String _generateDartCode(Map<String, List<Level>> levelsByTheme) {
  final buffer = StringBuffer();

  // Header
  buffer.writeln("// Generated file - DO NOT EDIT");
  buffer.writeln("// Generated on: ${DateTime.now().toIso8601String()}");
  buffer.writeln("// Total levels: ${levelsByTheme.values.fold(0, (sum, levels) => sum + levels.length)}");
  buffer.writeln();
  buffer.writeln("import '../../core/models/level.dart';");
  buffer.writeln("import '../../core/models/game_color.dart';");
  buffer.writeln("import '../../core/engine/container.dart';");
  buffer.writeln();

  buffer.writeln("/// Generated level pack with all 200 levels.");
  buffer.writeln("///");
  buffer.writeln("/// This file is automatically generated by bin/generate_levels.dart.");
  buffer.writeln("/// Do not edit manually - changes will be overwritten.");
  buffer.writeln("class GeneratedLevels {");
  buffer.writeln("  GeneratedLevels._();");
  buffer.writeln();

  // Generate constants for each theme
  for (final theme in levelsByTheme.keys) {
    final levels = levelsByTheme[theme]!;

    buffer.writeln("  /// ${levels.length} levels for $theme theme.");
    buffer.writeln("  static final List<Level> ${_themeVariableName(theme)} = [");

    for (int i = 0; i < levels.length; i++) {
      buffer.write(_generateLevelCode(levels[i], indent: '    '));
      if (i < levels.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }

    buffer.writeln("  ];");
    buffer.writeln();
  }

  // Generate lookup method
  buffer.writeln("  /// Get levels by theme name.");
  buffer.writeln("  static List<Level> getLevelsByTheme(String theme) {");
  buffer.writeln("    switch (theme) {");

  for (final theme in levelsByTheme.keys) {
    buffer.writeln("      case '$theme':");
    buffer.writeln("        return ${_themeVariableName(theme)};");
  }

  buffer.writeln("      default:");
  buffer.writeln("        throw ArgumentError('Unknown theme: \$theme');");
  buffer.writeln("    }");
  buffer.writeln("  }");
  buffer.writeln();

  // Generate all levels method
  buffer.writeln("  /// Get all levels across all themes.");
  buffer.writeln("  static List<Level> getAllLevels() {");
  buffer.writeln("    return [");
  for (final theme in levelsByTheme.keys) {
    buffer.writeln("      ...${_themeVariableName(theme)},");
  }
  buffer.writeln("    ];");
  buffer.writeln("  }");

  buffer.writeln("}");

  return buffer.toString();
}

/// Generate Dart code for a single level.
String _generateLevelCode(Level level, {String indent = ''}) {
  final buffer = StringBuffer();

  buffer.writeln("${indent}Level(");
  buffer.writeln("$indent  id: '${level.id}',");
  buffer.writeln("$indent  name: '${level.name}',");
  buffer.writeln("$indent  difficulty: Difficulty.${level.difficulty.name},");

  if (level.description != null) {
    buffer.writeln("$indent  description: '${level.description}',");
  }

  if (level.moveLimit != null) {
    buffer.writeln("$indent  moveLimit: ${level.moveLimit},");
  }

  if (level.starThresholds != null) {
    buffer.writeln(
        "$indent  starThresholds: const [${level.starThresholds!.join(', ')}],");
  }

  // Containers
  buffer.writeln("$indent  initialContainers: [");

  for (final container in level.initialContainers) {
    if (container.isEmpty) {
      buffer.writeln(
          "$indent    Container.empty(id: '${container.id}', capacity: ${container.capacity}),");
    } else {
      final colors = container.colors.map((c) => 'GameColor.${c.name}').join(', ');
      buffer.writeln(
          "$indent    Container.withColors(id: '${container.id}', colors: const [$colors], capacity: ${container.capacity}),");
    }
  }

  buffer.writeln("$indent  ],");
  buffer.write("$indent)");

  return buffer.toString();
}

/// Convert theme name to valid Dart variable name.
String _themeVariableName(String theme) {
  return '${theme.toLowerCase()}Levels';
}
