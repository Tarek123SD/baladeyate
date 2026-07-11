import 'dart:io';
import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:baladeyate/features/profile/repo/citizen_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required CitizenRepository citizenRepository,
    required FcmService fcmService,
  })  : _authRepository = authRepository,
        _citizenRepository = citizenRepository,
        _fcmService = fcmService,
        super(const AuthInitial());

  final AuthRepository _authRepository;
  final CitizenRepository _citizenRepository;
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

      // Signup only stores the identity on the account; the admin verification
      // request is created by verify-identity. Submit it automatically so the
      // authorization request reaches the dashboard right after registration.
      final verifiedUser = await _submitIdentityAfterSignup(
        nationalNumber: nationalNumber,
        identityImage: identityImage,
        fallbackUser: user,
      );

      emit(AuthSuccess(user: verifiedUser));
      await _fcmService.syncTokenWithBackend();
    } catch (e) {
      emit(AuthFailure(message: _messageFromError(e)));
    }
  }

  /// Sends the identity for verification after signup. Non-blocking: if it
  /// fails (e.g. national number is not 11 digits), signup still succeeds and
  /// the user can submit verification manually.
  Future<User> _submitIdentityAfterSignup({
    required String nationalNumber,
    required File identityImage,
    required User fallbackUser,
  }) async {
    final nationalId = nationalNumber.trim();
    if (nationalId.length != 11) return fallbackUser;

    try {
      final status = await _citizenRepository.verifyIdentity(
        nationalId: nationalId,
        identityImage: identityImage,
      );
      // verify-identity returns only the status, so keep the full user and
      // just update the verification fields.
      final updated = fallbackUser.copyWith(
        verificationStatus: status,
        verificationStatusLabel: verificationStatusLabel(status),
      );
      await _authRepository.persistUser(updated);
      return updated;
    } catch (_) {
      return fallbackUser;
    }
  }

  /// Applies a new verification status to the current user, preserving all
  /// other profile fields. Used after submitting identity verification.
  Future<void> applyVerificationStatus(String status) async {
    final current = state;
    if (current is! AuthSuccess) return;

    final updated = current.user.copyWith(
      verificationStatus: status,
      verificationStatusLabel: verificationStatusLabel(status),
    );
    emit(AuthSuccess(user: updated));
    await _authRepository.persistUser(updated);
  }

  /// Arabic label for a verification status value.
  static String verificationStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'موثّق';
      case 'pending':
        return 'قيد المراجعة';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'غير موثّق';
    }
  }

  /// Login with email and password.
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final fcmToken = await _fcmService.getToken();
      final user = await _authRepository.login(
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

  /// Restores a saved session when the app starts.
  Future<void> restoreSession() async {
    if (!_authRepository.hasStoredSession) {
      emit(const AuthLoggedOut());
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _authRepository.restoreSession();
      if (user != null) {
        emit(AuthSuccess(user: user));
        await _fcmService.syncTokenWithBackend();
      } else {
        emit(const AuthLoggedOut());
      }
    } catch (_) {
      emit(const AuthLoggedOut());
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
  Future<void> updateUser(User user) async {
    emit(AuthSuccess(user: user));
    await _authRepository.persistUser(user);
  }

  /// Re-fetches the current user from the API to pick up server-side changes
  /// (e.g. an admin approving identity verification).
  Future<void> refreshUser() async {
    final current = state;
    if (current is! AuthSuccess) return;

    final phoneNumber = current.user.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    try {
      final user =
          await _authRepository.refreshCurrentUser(phoneNumber: phoneNumber);
      emit(AuthSuccess(user: user));
      await _authRepository.persistUser(user);
    } catch (_) {
      // Keep the existing session if the refresh fails (e.g. offline).
    }
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
