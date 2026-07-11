import 'dart:async';

import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when auth state changes so redirects re-evaluate.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthCubit authCubit) {
    _subscription = authCubit.stream.listen(_onAuthStateChanged);
  }

  late final StreamSubscription<AuthState> _subscription;

  void _onAuthStateChanged(AuthState state) {
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
