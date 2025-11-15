import 'package:flutter/material.dart';
import '../../../../core/engine/container.dart' as game;
import '../../../../core/models/game_color.dart';
import 'container_widget.dart';

/// Example usage of the ContainerWidget.
///
/// This file demonstrates how to use the ContainerWidget in your game UI.
/// You can run this as a standalone demo or reference it when building levels.
///
/// TO USE IN YOUR APP:
/// 1. Import the container_widget.dart file
/// 2. Create Container models from your game state
/// 3. Render them using ContainerWidget
/// 4. Handle tap callbacks to implement game logic
///
class ContainerWidgetExample extends StatefulWidget {
  const ContainerWidgetExample({super.key});

  @override
  State<ContainerWidgetExample> createState() => _ContainerWidgetExampleState();
}

class _ContainerWidgetExampleState extends State<ContainerWidgetExample> {
  // Track which container is selected (null = none)
  String? selectedContainerId;

  // Example containers showing different states
  late List<game.Container> containers;

  @override
  void initState() {
    super.initState();
    _initializeContainers();
  }

  void _initializeContainers() {
    containers = [
      // Empty container
      game.Container.empty(id: '1'),

      // Partially filled
      game.Container.withColors(
        id: '2',
        colors: [GameColor.red, GameColor.blue],
      ),

      // Full container - mixed colors
      game.Container.withColors(
        id: '3',
        colors: [
          GameColor.yellow,
          GameColor.green,
          GameColor.yellow,
          GameColor.green,
        ],
      ),

      // Solved container - all same color
      game.Container.withColors(
        id: '4',
        colors: [
          GameColor.purple,
          GameColor.purple,
          GameColor.purple,
          GameColor.purple,
        ],
      ),

      // Another mixed container
      game.Container.withColors(
        id: '5',
        colors: [
          GameColor.orange,
          GameColor.pink,
          GameColor.cyan,
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container Widget Demo'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[900]!,
              Colors.blueGrey[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Tap containers to select them',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (selectedContainerId != null)
                Text(
                  'Selected: Container $selectedContainerId',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 30),
              // Display containers in a row
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: containers.map((container) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // The container widget
                              ContainerWidget(
                                container: container,
                                isSelected: selectedContainerId == container.id,
                                onTap: () => _handleContainerTap(container.id),
                                size: const Size(80, 180),
                              ),
                              const SizedBox(height: 12),
                              // Label
                              Text(
                                _getContainerLabel(container),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Examples section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Different Sizes:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Small
                        Column(
                          children: [
                            ContainerWidget(
                              container: containers[1],
                              size: const Size(50, 120),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Small',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                        // Medium
                        Column(
                          children: [
                            ContainerWidget(
                              container: containers[1],
                              size: const Size(70, 150),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Medium',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                        // Large
                        Column(
                          children: [
                            ContainerWidget(
                              container: containers[1],
                              size: const Size(90, 200),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Large',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContainerTap(String containerId) {
    setState(() {
      // Toggle selection
      if (selectedContainerId == containerId) {
        selectedContainerId = null;
      } else {
        selectedContainerId = containerId;
      }
    });

    // In a real game, you would:
    // 1. Check if a container is already selected
    // 2. If no selection, select this container
    // 3. If selection exists, try to pour from selected to this one
    // 4. Validate the move using GameRules
    // 5. Update game state via GameController
    // 6. Clear selection
  }

  String _getContainerLabel(game.Container container) {
    if (container.isEmpty) {
      return 'Empty';
    }
    if (container.isSolved) {
      return 'Solved!';
    }
    return '${container.colors.length}/${container.capacity}';
  }
}

/// Minimal example showing just the widget usage
class MinimalExample extends StatelessWidget {
  const MinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a container with some colors
    final container = game.Container.withColors(
      id: 'example',
      colors: [
        GameColor.red,
        GameColor.blue,
        GameColor.blue,
      ],
    );

    // Render it
    return Scaffold(
      body: Center(
        child: ContainerWidget(
          container: container,
          onTap: () {
            print('Container tapped!');
          },
        ),
      ),
    );
  }
}

/// Example showing responsive sizing
class ResponsiveSizingExample extends StatelessWidget {
  const ResponsiveSizingExample({super.key});

  @override
  Widget build(BuildContext context) {
    final container = game.Container.withColors(
      id: 'responsive',
      colors: [GameColor.green, GameColor.yellow],
    );

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate size based on available space
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            // Make container 10% of width and 30% of height
            final containerWidth = maxWidth * 0.1;
            final containerHeight = maxHeight * 0.3;

            return ContainerWidget(
              container: container,
              size: Size(containerWidth, containerHeight),
            );
          },
        ),
      ),
    );
  }
}

/// Example showing the SizedContainerWidget
class AutoSizedExample extends StatelessWidget {
  const AutoSizedExample({super.key});

  @override
  Widget build(BuildContext context) {
    final container = game.Container.withColors(
      id: 'auto',
      colors: [GameColor.purple, GameColor.orange],
      capacity: 5, // Different capacity
    );

    return Scaffold(
      body: Center(
        child: SizedContainerWidget(
          container: container,
          // Size automatically calculated from capacity
          unitWidth: 25, // 5 × 25 = 125px wide
          unitHeight: 50, // 5 × 50 = 250px tall
        ),
      ),
    );
  }
}
