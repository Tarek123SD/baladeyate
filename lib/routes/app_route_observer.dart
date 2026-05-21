import 'package:baladeyate/routes/navigation_logger.dart';
import 'package:flutter/material.dart';

/// Observes navigator stack changes and logs them to the terminal.
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    NavigationLogger.logStackAction(
      'PUSH',
      to: _routeName(route),
      from: previousRoute != null ? _routeName(previousRoute) : null,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    NavigationLogger.logStackAction(
      'POP',
      to: previousRoute != null ? _routeName(previousRoute) : null,
      from: _routeName(route),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      NavigationLogger.logStackAction(
        'REPLACE',
        to: _routeName(newRoute),
        from: oldRoute != null ? _routeName(oldRoute) : null,
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    NavigationLogger.logStackAction(
      'REMOVE',
      to: previousRoute != null ? _routeName(previousRoute) : null,
      from: _routeName(route),
    );
  }

  String? _routeName(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    return route.settings.arguments?.toString();
  }
}

final appRouteObserver = AppRouteObserver();
