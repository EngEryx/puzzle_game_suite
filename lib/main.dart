import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';

/// App Entry Point
///
/// KEY ARCHITECTURE DECISION: Using ProviderScope
///
/// ProviderScope wraps the entire app and provides the Riverpod state
/// management context. This is similar to:
/// - Redux Provider in React
/// - Service Container in Laravel
/// - Application Context in Android
///
/// WHY Riverpod for game state?
/// 1. Compile-safe: Errors caught at compile time, not runtime
/// 2. Testable: Easy to mock providers in tests
/// 3. No BuildContext needed: Access state from anywhere
/// 4. Immutable by default: Fits game state pattern
/// 5. Great DevTools: Debug state easily
void main() {
  runApp(
    const ProviderScope(
      child: PuzzleGameApp(),
    ),
  );
}

/// Root application widget
class PuzzleGameApp extends StatelessWidget {
  const PuzzleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Puzzle Game Suite',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      // We'll customize this more as we build out the UI
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Elevated button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 50),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // Dark theme (we'll add theme switching later)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Routing configuration from config/routes.dart
      routerConfig: router,
    );
  }
}
