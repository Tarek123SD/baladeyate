/// Events for the AuthBloc
/// Events represent user actions or triggers
abstract class AuthEvent {
  const AuthEvent();
}

/// Event triggered when user attempts to login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });
}
