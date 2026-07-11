import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const PasswordResetInitial());

  final AuthRepository _authRepository;

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

  Future<bool> resetPassword({
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
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
