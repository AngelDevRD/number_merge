import 'package:go_router/go_router.dart';

import 'presentation/screens/achievements_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/stats_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);
