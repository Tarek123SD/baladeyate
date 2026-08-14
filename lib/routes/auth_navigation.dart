import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/features/auth/models/user.dart';

/// Resolves the home route for an authenticated user based on their role.
String homeRouteFor(User? user) {
  if (user == null) return '/login';
  return user.appRole.homeRoute;
}

/// Citizen-only shell routes (bottom navigation branches).
const citizenShellRoutes = {
  '/main',
  '/transactions',
  '/track',
  '/donations',
  '/profile',
  '/complains',
};

/// Top-level [StatefulShellRoute] tab paths.
///
/// These must be opened with [GoRouter.go] (not [GoRouter.push]). Pushing a
/// shell tab while another shell page is already in the stack duplicates the
/// shell's page key and throws `!keyReservation.contains(key)`.
const indexedShellTabRoutes = {
  '/main',
  '/transactions',
  '/track',
  '/donations',
  '/profile',
  '/delegate/home',
  '/delegate/tasks',
  '/delegate/map',
  '/delegate/buildings',
};

bool isIndexedShellTabRoute(String path) =>
    indexedShellTabRoutes.contains(path);

/// Delegate field-work routes.
const delegateRoutes = {
  '/delegate/home',
  '/delegate/tasks',
  '/delegate/map',
  '/delegate/buildings',
  '/delegate/cemetery-map',
  '/tasks',
  '/info',
  '/floor',
  '/apartment',
  '/people',
};

/// Routes accessible without authentication.
const publicRoutes = {
  '/splash',
  '/login',
  '/signup',
  '/forgot-password',
  '/reset-password',
};

/// Routes shared by all authenticated roles.
const sharedAuthenticatedRoutes = {
  '/notifications',
  '/settings',
  '/graves',
  '/reset-password',
};

bool isCitizenRoute(String path) =>
    citizenShellRoutes.contains(path) ||
    path.startsWith('/complains') ||
    path.startsWith('/track') ||
    path.startsWith('/transactions') ||
    path.startsWith('/digital-documents');

bool isDelegateRoute(String path) =>
    delegateRoutes.contains(path) ||
    path.startsWith('/delegate/') ||
    path.startsWith('/building/');

bool isPublicRoute(String path) => publicRoutes.contains(path);

bool isSharedAuthenticatedRoute(String path) =>
    sharedAuthenticatedRoutes.contains(path);
