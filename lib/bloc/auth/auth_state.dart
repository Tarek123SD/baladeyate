import 'package:baladeyate/models/user.dart';

/// States for the AuthBloc
/// States represent the current state of authentication
abstract class AuthState {
  const AuthState();
}

/// Initial state - no login attempt yet
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - login request is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state - user logged in successfully
class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});
}

/// Failure state - login failed with an error
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});
}
