import 'package:baladeyate/core/navigation/main_navigation_screen.dart';
import 'package:baladeyate/features/apartment/presentation/apartment_screen.dart';
import 'package:baladeyate/features/auth/presentation/auth_screen.dart';
import 'package:baladeyate/features/auth/presentation/signup_screen.dart';
import 'package:baladeyate/features/auth/presentation/splash_screen.dart';
import 'package:baladeyate/features/building/presentation/building_complex_screen.dart';
import 'package:baladeyate/features/complaints/presentation/complaints_screen.dart';
import 'package:baladeyate/features/complaints/presentation/track_complaints_screen.dart';
import 'package:baladeyate/features/donations/presentation/donations_screen.dart';
import 'package:baladeyate/features/floor/presentation/floor_screen.dart';
import 'package:baladeyate/features/home/presentation/home_screen.dart';
import 'package:baladeyate/features/notifications/presentation/notifications_screen.dart';
import 'package:baladeyate/features/people/presentation/people_screen.dart';
import 'package:baladeyate/features/profile/presentation/profile_screen.dart';
import 'package:baladeyate/features/settings/presentation/settings_screen.dart';
import 'package:baladeyate/features/daily_tasks/daily_tasks_screen.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:baladeyate/routes/navigation_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = _createAppRouter();

GoRouter _createAppRouter() {
  final router = GoRouter(
    initialLocation: '/tasks',
    debugLogDiagnostics: kDebugMode,
    observers: [appRouteObserver],
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/complains',
        builder: (context, state) => const ComplaintsScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const DailyTasksScreen(),
      ),
      GoRoute(
        path: '/info',
        builder: (context, state) => const BuildingComplexScreen(),
      ),
      GoRoute(
        path: '/floor',
        builder: (context, state) => const FloorScreen(),
      ),
      GoRoute(
        path: '/apartment',
        builder: (context, state) => const ApartmentScreen(),
      ),
      GoRoute(
        path: '/people',
        builder: (context, state) => const PeopleScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donations',
                builder: (context, state) => const DonationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/track',
                builder: (context, state) => const TrackComplaintsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  NavigationLogger.attach(router);
  return router;
}
