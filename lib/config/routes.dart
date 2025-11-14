import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/levels/presentation/level_selector_screen.dart';
import '../features/achievements/presentation/achievements_screen.dart';

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
/// /levels -> LevelSelectorScreen (level selection)
/// /game -> GameScreen (quick play with tutorial level)
/// /game/:levelId -> GameScreen (play specific level)
/// /achievements -> AchievementsScreen (achievements)
/// /settings -> SettingsScreen (configuration)
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectorScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = state.pathParameters['levelId'];
        // Pass levelId to GameScreen (will need to update GameScreen to accept it)
        return GameScreen(levelId: levelId);
      },
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  // Error page (in case of invalid routes)
  errorBuilder: (context, state) => const HomeScreen(),
);
