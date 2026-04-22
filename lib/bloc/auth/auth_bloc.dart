import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/bloc/auth/auth_event.dart';
import 'package:baladeyate/bloc/auth/auth_state.dart';
import 'package:baladeyate/services/auth_service.dart';

/// AuthBloc handles authentication logic
/// Receives events and emits states based on the event and service response
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(const AuthInitial()) {
    // Register event handlers
    on<LoginRequested>(_onLoginRequested);
  }

  /// Handles LoginRequested event
  /// Calls AuthService.login and emits appropriate state
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit loading state
    emit(const AuthLoading());

    try {
      // Call the auth service to login
      final user = await authService.login(event.email, event.password);

      // Emit success state with the user
      emit(AuthSuccess(user: user));
    } catch (e) {
      // Emit failure state with error message
      emit(AuthFailure(message: e.toString()));
    }
  }
}
