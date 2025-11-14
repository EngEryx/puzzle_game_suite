import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_game_suite/core/engine/container.dart';
import 'package:puzzle_game_suite/core/models/game_color.dart';

void main() {
  group('Container Creation', () {
    test('creates empty container with default capacity', () {
      final container = Container.empty(id: 'test1');

      expect(container.id, equals('test1'));
      expect(container.colors, isEmpty);
      expect(container.capacity, equals(4));
    });

    test('creates empty container with custom capacity', () {
      final container = Container.empty(id: 'test2', capacity: 6);

      expect(container.id, equals('test2'));
      expect(container.colors, isEmpty);
      expect(container.capacity, equals(6));
    });

    test('creates container with initial colors', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue],
      );

      expect(container.id, equals('test3'));
      expect(container.colors.length, equals(2));
      expect(container.colors[0], equals(GameColor.red));
      expect(container.colors[1], equals(GameColor.blue));
      expect(container.capacity, equals(4));
    });

    test('creates container with initial colors and custom capacity', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
        capacity: 5,
      );

      expect(container.id, equals('test4'));
      expect(container.colors.length, equals(3));
      expect(container.capacity, equals(5));
    });

    test('creates immutable colors list via withColors factory', () {
      final originalColors = [GameColor.red, GameColor.blue];
      final container = Container.withColors(
        id: 'test5',
        colors: originalColors,
      );

      // Modifying original list should not affect container
      originalColors.add(GameColor.green);

      expect(container.colors.length, equals(2));
      expect(container.colors, equals([GameColor.red, GameColor.blue]));
    });
  });

  group('isEmpty Property', () {
    test('returns true for empty container', () {
      final container = Container.empty(id: 'test1');

      expect(container.isEmpty, isTrue);
    });

    test('returns false for container with one color', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
      );

      expect(container.isEmpty, isFalse);
    });

    test('returns false for container with multiple colors', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      expect(container.isEmpty, isFalse);
    });
  });

  group('isFull Property', () {
    test('returns false for empty container', () {
      final container = Container.empty(id: 'test1', capacity: 4);

      expect(container.isFull, isFalse);
    });

    test('returns false for partially filled container', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      expect(container.isFull, isFalse);
    });

    test('returns true when container is at capacity', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
        capacity: 4,
      );

      expect(container.isFull, isTrue);
    });

    test('returns true when container exceeds capacity', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow, GameColor.purple],
        capacity: 4,
      );

      expect(container.isFull, isTrue);
    });

    test('returns true for single capacity container with one color', () {
      final container = Container.withColors(
        id: 'test5',
        colors: [GameColor.red],
        capacity: 1,
      );

      expect(container.isFull, isTrue);
    });
  });

  group('isSolved Property', () {
    test('returns true for empty container', () {
      final container = Container.empty(id: 'test1');

      expect(container.isSolved, isTrue);
    });

    test('returns false for partially filled container with same colors', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red, GameColor.red],
        capacity: 4,
      );

      expect(container.isSolved, isFalse);
    });

    test('returns true for full container with all same colors', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.red, GameColor.red, GameColor.red],
        capacity: 4,
      );

      expect(container.isSolved, isTrue);
    });

    test('returns false for full container with different colors', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
        capacity: 4,
      );

      expect(container.isSolved, isFalse);
    });

    test('returns false for full container with mostly same colors', () {
      final container = Container.withColors(
        id: 'test5',
        colors: [GameColor.red, GameColor.red, GameColor.red, GameColor.blue],
        capacity: 4,
      );

      expect(container.isSolved, isFalse);
    });

    test('returns true for single capacity container with one color', () {
      final container = Container.withColors(
        id: 'test6',
        colors: [GameColor.red],
        capacity: 1,
      );

      expect(container.isSolved, isTrue);
    });
  });

  group('topColor Getter', () {
    test('returns null for empty container', () {
      final container = Container.empty(id: 'test1');

      expect(container.topColor, isNull);
    });

    test('returns the only color for single color container', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
      );

      expect(container.topColor, equals(GameColor.red));
    });

    test('returns the last color for multiple colors', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      expect(container.topColor, equals(GameColor.green));
    });

    test('returns the top color even when all colors are the same', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.red, GameColor.red],
      );

      expect(container.topColor, equals(GameColor.red));
    });
  });

  group('topColorCount Calculation', () {
    test('returns 0 for empty container', () {
      final container = Container.empty(id: 'test1');

      expect(container.topColorCount, equals(0));
    });

    test('returns 1 for single color', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
      );

      expect(container.topColorCount, equals(1));
    });

    test('returns 1 when top color differs from others', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      expect(container.topColorCount, equals(1));
    });

    test('returns correct count for multiple same colors at top', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.blue, GameColor.blue],
      );

      expect(container.topColorCount, equals(3));
    });

    test('returns correct count when all colors are the same', () {
      final container = Container.withColors(
        id: 'test5',
        colors: [GameColor.red, GameColor.red, GameColor.red, GameColor.red],
      );

      expect(container.topColorCount, equals(4));
    });

    test('returns correct count when only top two match', () {
      final container = Container.withColors(
        id: 'test6',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.green],
      );

      expect(container.topColorCount, equals(2));
    });

    test('handles alternating colors correctly', () {
      final container = Container.withColors(
        id: 'test7',
        colors: [GameColor.red, GameColor.blue, GameColor.red, GameColor.blue],
      );

      expect(container.topColorCount, equals(1));
    });
  });

  group('availableSpace Calculation', () {
    test('returns capacity for empty container', () {
      final container = Container.empty(id: 'test1', capacity: 4);

      expect(container.availableSpace, equals(4));
    });

    test('returns correct space for partially filled container', () {
      final container = Container.withColors(
        id: 'test2',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      expect(container.availableSpace, equals(2));
    });

    test('returns 0 for full container', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
        capacity: 4,
      );

      expect(container.availableSpace, equals(0));
    });

    test('returns 1 for almost full container', () {
      final container = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
        capacity: 4,
      );

      expect(container.availableSpace, equals(1));
    });
  });

  group('addColor Immutability', () {
    test('returns new container with added color', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
      );

      final updated = original.addColor(GameColor.blue);

      expect(updated.colors.length, equals(2));
      expect(updated.colors[0], equals(GameColor.red));
      expect(updated.colors[1], equals(GameColor.blue));
    });

    test('does not modify original container', () {
      final original = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
      );

      final updated = original.addColor(GameColor.blue);

      expect(original.colors.length, equals(1));
      expect(original.colors[0], equals(GameColor.red));
      expect(updated.colors.length, equals(2));
    });

    test('preserves container id and capacity', () {
      final original = Container.withColors(
        id: 'test3',
        colors: [GameColor.red],
        capacity: 5,
      );

      final updated = original.addColor(GameColor.blue);

      expect(updated.id, equals('test3'));
      expect(updated.capacity, equals(5));
    });

    test('adds color to empty container', () {
      final original = Container.empty(id: 'test4');

      final updated = original.addColor(GameColor.red);

      expect(updated.colors.length, equals(1));
      expect(updated.colors[0], equals(GameColor.red));
    });

    test('can add multiple colors sequentially', () {
      final original = Container.empty(id: 'test5');

      final step1 = original.addColor(GameColor.red);
      final step2 = step1.addColor(GameColor.blue);
      final step3 = step2.addColor(GameColor.green);

      expect(original.colors.length, equals(0));
      expect(step1.colors.length, equals(1));
      expect(step2.colors.length, equals(2));
      expect(step3.colors.length, equals(3));
      expect(step3.colors, equals([GameColor.red, GameColor.blue, GameColor.green]));
    });
  });

  group('addColors Immutability', () {
    test('returns new container with multiple colors added', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
      );

      final updated = original.addColors([GameColor.blue, GameColor.green]);

      expect(updated.colors.length, equals(3));
      expect(updated.colors, equals([GameColor.red, GameColor.blue, GameColor.green]));
    });

    test('does not modify original container', () {
      final original = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
      );

      final updated = original.addColors([GameColor.blue, GameColor.green]);

      expect(original.colors.length, equals(1));
      expect(updated.colors.length, equals(3));
    });

    test('handles empty list of colors', () {
      final original = Container.withColors(
        id: 'test3',
        colors: [GameColor.red],
      );

      final updated = original.addColors([]);

      expect(updated.colors.length, equals(1));
      expect(updated.colors[0], equals(GameColor.red));
    });
  });

  group('removeTopColors Immutability', () {
    test('returns new container with top color removed', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      final updated = original.removeTopColors(1);

      expect(updated.colors.length, equals(2));
      expect(updated.colors, equals([GameColor.red, GameColor.blue]));
    });

    test('does not modify original container', () {
      final original = Container.withColors(
        id: 'test2',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      final updated = original.removeTopColors(1);

      expect(original.colors.length, equals(3));
      expect(updated.colors.length, equals(2));
    });

    test('removes multiple colors from top', () {
      final original = Container.withColors(
        id: 'test3',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
      );

      final updated = original.removeTopColors(2);

      expect(updated.colors.length, equals(2));
      expect(updated.colors, equals([GameColor.red, GameColor.blue]));
    });

    test('removes all colors when count equals length', () {
      final original = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue, GameColor.green],
      );

      final updated = original.removeTopColors(3);

      expect(updated.colors, isEmpty);
      expect(updated.isEmpty, isTrue);
    });

    test('preserves container id and capacity', () {
      final original = Container.withColors(
        id: 'test5',
        colors: [GameColor.red, GameColor.blue],
        capacity: 5,
      );

      final updated = original.removeTopColors(1);

      expect(updated.id, equals('test5'));
      expect(updated.capacity, equals(5));
    });

    test('can remove colors sequentially', () {
      final original = Container.withColors(
        id: 'test6',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
      );

      final step1 = original.removeTopColors(1);
      final step2 = step1.removeTopColors(1);

      expect(original.colors.length, equals(4));
      expect(step1.colors.length, equals(3));
      expect(step2.colors.length, equals(2));
      expect(step2.colors, equals([GameColor.red, GameColor.blue]));
    });
  });

  group('removeTopColors Edge Cases', () {
    test('throws ArgumentError when removing more colors than exist', () {
      final container = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
      );

      expect(
        () => container.removeTopColors(3),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when removing from empty container', () {
      final container = Container.empty(id: 'test2');

      expect(
        () => container.removeTopColors(1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError with descriptive message', () {
      final container = Container.withColors(
        id: 'test3',
        colors: [GameColor.red],
      );

      expect(
        () => container.removeTopColors(5),
        throwsA(
          predicate((e) =>
            e is ArgumentError &&
            e.message.toString().contains('Cannot remove 5 colors, only have 1')
          ),
        ),
      );
    });

    test('handles removing 0 colors', () {
      final original = Container.withColors(
        id: 'test4',
        colors: [GameColor.red, GameColor.blue],
      );

      final updated = original.removeTopColors(0);

      expect(updated.colors.length, equals(2));
      expect(updated.colors, equals([GameColor.red, GameColor.blue]));
    });
  });

  group('copyWith Method', () {
    test('creates copy with updated id', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final updated = original.copyWith(id: 'test2');

      expect(updated.id, equals('test2'));
      expect(updated.colors, equals([GameColor.red]));
      expect(updated.capacity, equals(4));
    });

    test('creates copy with updated colors', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final updated = original.copyWith(colors: [GameColor.blue, GameColor.green]);

      expect(updated.id, equals('test1'));
      expect(updated.colors, equals([GameColor.blue, GameColor.green]));
      expect(updated.capacity, equals(4));
    });

    test('creates copy with updated capacity', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final updated = original.copyWith(capacity: 6);

      expect(updated.id, equals('test1'));
      expect(updated.colors, equals([GameColor.red]));
      expect(updated.capacity, equals(6));
    });

    test('creates copy with all properties updated', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final updated = original.copyWith(
        id: 'test2',
        colors: [GameColor.blue, GameColor.green],
        capacity: 6,
      );

      expect(updated.id, equals('test2'));
      expect(updated.colors, equals([GameColor.blue, GameColor.green]));
      expect(updated.capacity, equals(6));
    });

    test('creates copy with no changes when no parameters provided', () {
      final original = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final updated = original.copyWith();

      expect(updated.id, equals('test1'));
      expect(updated.colors, equals([GameColor.red]));
      expect(updated.capacity, equals(4));
    });
  });

  group('Equality and HashCode', () {
    test('containers with same properties are equal', () {
      final container1 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      expect(container1, equals(container2));
      expect(container1.hashCode, equals(container2.hashCode));
    });

    test('containers with different ids are not equal', () {
      final container1 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'test2',
        colors: [GameColor.red],
        capacity: 4,
      );

      expect(container1, isNot(equals(container2)));
    });

    test('containers with different colors are not equal', () {
      final container1 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'test1',
        colors: [GameColor.blue],
        capacity: 4,
      );

      expect(container1, isNot(equals(container2)));
    });

    test('containers with different capacities are not equal', () {
      final container1 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 6,
      );

      expect(container1, isNot(equals(container2)));
    });

    test('containers with different color counts are not equal', () {
      final container1 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      expect(container1, isNot(equals(container2)));
    });

    test('identical containers are equal', () {
      final container = Container.withColors(
        id: 'test1',
        colors: [GameColor.red],
        capacity: 4,
      );

      expect(container, equals(container));
    });

    test('empty containers with same properties are equal', () {
      final container1 = Container.empty(id: 'test1', capacity: 4);
      final container2 = Container.empty(id: 'test1', capacity: 4);

      expect(container1, equals(container2));
    });
  });

  group('String Representations', () {
    test('toString returns proper string format', () {
      final container = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      final str = container.toString();

      expect(str, contains('Container'));
      expect(str, contains('test1'));
      expect(str, contains('4'));
    });

    test('toDebugString shows empty container', () {
      final container = Container.empty(id: 'test1');

      final debug = container.toDebugString();

      expect(debug, contains('test1'));
      expect(debug, contains('[empty]'));
    });

    test('toDebugString shows container with colors', () {
      final container = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      final debug = container.toDebugString();

      expect(debug, contains('test1'));
      expect(debug, contains('red'));
      expect(debug, contains('blue'));
      expect(debug, contains('2/4'));
    });

    test('toDebugString shows full container', () {
      final container = Container.withColors(
        id: 'test1',
        colors: [GameColor.red, GameColor.blue, GameColor.green, GameColor.yellow],
        capacity: 4,
      );

      final debug = container.toDebugString();

      expect(debug, contains('4/4'));
    });
  });

  group('Complex Scenarios', () {
    test('can simulate a complete pour sequence', () {
      // Start with a full source container
      final source = Container.withColors(
        id: 'source',
        colors: [GameColor.red, GameColor.red, GameColor.blue, GameColor.blue],
        capacity: 4,
      );

      // Start with an empty target container
      final target = Container.empty(id: 'target', capacity: 4);

      // Pour top 2 blues
      final bluesRemoved = source.removeTopColors(2);
      final targetWithBlues = target.addColors([GameColor.blue, GameColor.blue]);

      // Verify state
      expect(bluesRemoved.colors, equals([GameColor.red, GameColor.red]));
      expect(bluesRemoved.topColor, equals(GameColor.red));
      expect(targetWithBlues.colors, equals([GameColor.blue, GameColor.blue]));
      expect(targetWithBlues.topColorCount, equals(2));
    });

    test('validates move constraints', () {
      final source = Container.withColors(
        id: 'source',
        colors: [GameColor.red, GameColor.red, GameColor.blue],
        capacity: 4,
      );

      final target = Container.withColors(
        id: 'target',
        colors: [GameColor.green, GameColor.green, GameColor.green],
        capacity: 4,
      );

      // Check if move is valid (top colors match and space available)
      final canPour = !source.isEmpty &&
          target.availableSpace > 0 &&
          (target.isEmpty || source.topColor == target.topColor);

      expect(canPour, isFalse); // Different top colors
    });

    test('detects solved game state', () {
      final container1 = Container.withColors(
        id: 'c1',
        colors: [GameColor.red, GameColor.red, GameColor.red, GameColor.red],
        capacity: 4,
      );

      final container2 = Container.withColors(
        id: 'c2',
        colors: [GameColor.blue, GameColor.blue, GameColor.blue, GameColor.blue],
        capacity: 4,
      );

      final container3 = Container.empty(id: 'c3', capacity: 4);

      final allSolved = container1.isSolved &&
          container2.isSolved &&
          container3.isSolved;

      expect(allSolved, isTrue);
    });

    test('handles undo/redo scenario', () {
      final initial = Container.withColors(
        id: 'test',
        colors: [GameColor.red, GameColor.blue],
        capacity: 4,
      );

      // Perform action
      final afterAdd = initial.addColor(GameColor.green);

      // Undo (just use the saved initial state)
      expect(initial.colors.length, equals(2));

      // Redo (just use the saved afterAdd state)
      expect(afterAdd.colors.length, equals(3));

      // Verify immutability - both states still valid
      expect(initial.colors, equals([GameColor.red, GameColor.blue]));
      expect(afterAdd.colors, equals([GameColor.red, GameColor.blue, GameColor.green]));
    });
  });
}
