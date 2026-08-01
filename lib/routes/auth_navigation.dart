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
  '/profile',
  '/donations',
  '/track',
  '/complains',
  '/transactions',
};

/// Delegate field-work routes.
const delegateRoutes = {
  '/delegate/home',
  '/delegate/map',
  '/delegate/tasks',
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
