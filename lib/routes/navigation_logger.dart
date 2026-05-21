import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

/// Prints route changes to the terminal while the app runs in debug mode.
class NavigationLogger {
  NavigationLogger(this._router);

  final GoRouter _router;
  String? _lastLocation;

  static void attach(GoRouter router) {
    NavigationLogger(router)._attach();
  }

  void _attach() {
    _router.routerDelegate.addListener(_onRouteChanged);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _logRoute(isInitial: true);
    });
  }

  void _onRouteChanged() {
    _logRoute();
  }

  void _logRoute({bool isInitial = false}) {
    if (!kDebugMode) return;

    final location = _currentLocation();
    if (location == null) return;
    if (!isInitial && location == _lastLocation) return;
    _lastLocation = location;

    final action = isInitial ? 'START' : 'GO';
    final uri = _currentUri();
    final query = uri != null && uri.hasQuery ? ' | query: ${uri.query}' : '';

    // ignore: avoid_print
    print('[Navigation] $action → $location$query');
  }

  String? _currentLocation() {
    try {
      return _router.state.matchedLocation;
    } on StateError {
      return null;
    }
  }

  Uri? _currentUri() {
    try {
      return _router.state.uri;
    } on StateError {
      return null;
    }
  }

  static void logStackAction(
    String action, {
    required String? to,
    String? from,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer('[Navigation] $action → ${to ?? 'unknown'}');
    if (from != null && from.isNotEmpty) {
      buffer.write(' (from: $from)');
    }
    // ignore: avoid_print
    print(buffer.toString());
  }
}
