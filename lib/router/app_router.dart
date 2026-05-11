import 'package:baladeyate/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

// Navigation
import 'package:baladeyate/navigations/main_navigation_screen.dart';

// Screens
import 'package:baladeyate/screens/complains_page.dart';
import 'package:baladeyate/screens/login.dart';
import 'package:baladeyate/screens/donations.dart';
import 'package:baladeyate/screens/family_profile.dart';
import 'package:baladeyate/screens/main_page.dart';
import 'package:baladeyate/screens/notifications.dart';
import 'package:baladeyate/screens/settings.dart';
import 'package:baladeyate/screens/signup.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // =========================
    // Routes WITHOUT Bottom Bar
    // =========================
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LogIn(),
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUP(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const Notifications(),
    ),

    GoRoute(
      path: '/complains',
      builder: (context, state) => const ComplaintScreen(),
    ),

    // =========================
    // Routes WITH Bottom Bar
    // =========================

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationScreen(
          navigationShell: navigationShell,
        );
      },
      branches: [
        // HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainPage(),
            ),
          ],
        ),

        // PROFILE
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const FamilyProfile(),
            ),
          ],
        ),

        // DONATIONS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/donations',
              builder: (context, state) => const Donations(),
            ),
          ],
        ),

        // SETTINGS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const Settings(),
            ),
          ],
        ),
      ],
    ),
  ],
);




// #### previes implementation before using StatefulShellRoute for bottom navigation
// final GoRouter _router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const MainPage(),
//     ),
//     GoRoute(
//       path: '/login',
//       builder: (context, state) => const LogIn(),
//     ),
//     GoRoute(
//       path: '/main',
//       builder: (context, state) => const MainPage(),
//     ),
//     GoRoute(
//       path: '/complains',
//       builder: (context, state) => const ComplaintScreen(),
//     ),
//     GoRoute(
//       path: '/family-profile',
//       builder: (context, state) => const FamilyProfile(),
//     ),
//     GoRoute(
//       path: '/signup',
//       builder: (context, state) => const SignUP(),
//     ),
//     GoRoute(
//       path: '/notifications',
//       builder: (context, state) => const Notifications(),
//     ),
//     GoRoute(
//       path: '/donations',
//       builder: (context, state) => const Donations(),
//     ),
//     GoRoute(
//       path: '/settings',
//       builder: (context, state) => const Settings(),
//     ),
//   ],
// );