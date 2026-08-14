import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const PasswordResetInitial());

  final AuthRepository _authRepository;

  /// Step 1 – POST /auth/forgot-password: sends OTP email.
  Future<bool> sendOtp(String email) async {
    emit(const PasswordResetLoading());
    try {
      final message = await _authRepository.forgotPassword(email: email);
      emit(PasswordResetOtpSent(email: email, message: message));
      return true;
    } catch (error) {
      emit(PasswordResetFailure(message: _messageFromError(error)));
      return false;
    }
  }

  /// Step 2 – POST /auth/verify-otp: verifies OTP and returns reset_token.
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    emit(const PasswordResetLoading());
    try {
      final resetToken = await _authRepository.verifyOtp(
        email: email,
        otp: otp,
      );
      emit(PasswordResetOtpVerified(email: email, resetToken: resetToken));
      return resetToken;
    } catch (error) {
      emit(PasswordResetFailure(message: _messageFromError(error)));
      return null;
    }
  }

  /// Step 3 – POST /auth/reset-password: sets new password using reset_token.
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const PasswordResetLoading());
    try {
      final message = await _authRepository.resetPassword(
        email: email,
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(PasswordResetSuccess(message: message));
      return true;
    } catch (error) {
      emit(PasswordResetFailure(message: _messageFromError(error)));
      return false;
    }
  }

  /// Legacy single-step reset (kept for backward compat with old screen).
  Future<bool> resetPasswordLegacy({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const PasswordResetLoading());
    try {
      final message = await _authRepository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      emit(PasswordResetSuccess(message: message));
      return true;
    } catch (error) {
      emit(PasswordResetFailure(message: _messageFromError(error)));
      return false;
    }
  }

  void clearFailure() {
    if (state is PasswordResetFailure) {
      emit(const PasswordResetInitial());
    }
  }

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'حدث خطأ غير متوقع',
    );
  }
}
