import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/settings/settings_screen.dart';

/// App routing configuration
///
/// WHY go_router?
/// - Declarative routing (similar to React Router)
/// - Deep linking support (important for app stores)
/// - URL-based navigation (cleaner than named routes)
/// - Type-safe route parameters
/// - Built-in error handling
///
/// Route structure:
/// / -> HomeScreen (entry point)
/// /game -> GameScreen (where gameplay happens)
/// /settings -> SettingsScreen (configuration)
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  // Error page (in case of invalid routes)
  errorBuilder: (context, state) => const HomeScreen(),
);
