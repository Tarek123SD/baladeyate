import 'dart:io';
import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required FcmService fcmService,
  })  : _authRepository = authRepository,
        _fcmService = fcmService,
        super(const AuthInitial());

  final AuthRepository _authRepository;
  final FcmService _fcmService;

  /// Signup with email, password, and identity image
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String nationalNumber,
    required String phoneNumber,
    required String email,
    required String password,
    required String passwordConfirmation,
    required File identityImage,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signup(
        firstName: firstName,
        lastName: lastName,
        nationalNumber: nationalNumber,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        identityImage: identityImage,
      );
      emit(AuthSuccess(user: user));
      await _fcmService.syncTokenWithBackend();
    } catch (e) {
      emit(AuthFailure(message: _messageFromError(e)));
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final fcmToken = await _fcmService.getToken();
      final user = await _authRepository.loginCitizen(
        email,
        password,
        fcmToken: fcmToken,
      );
      emit(AuthSuccess(user: user));
      await _fcmService.syncTokenWithBackend();
    } catch (e) {
      emit(AuthFailure(message: _messageFromError(e)));
    }
  }

  /// Logout from the API and clear the local session.
  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(message: _messageFromError(e)));
    }
  }

  /// Updates the in-memory user after profile or verification changes.
  void updateUser(User user) {
    emit(AuthSuccess(user: user));
  }

  /// Persists an FCM token for push notifications when available.
  Future<void> registerFcmToken(String token) async {
    if (token.isEmpty) return;
    try {
      await _authRepository.updateFcmToken(token);
    } catch (_) {
      // Non-blocking: login still succeeds without push registration.
    }
  }

  Future<void> syncPushToken() => _fcmService.syncTokenWithBackend();

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
