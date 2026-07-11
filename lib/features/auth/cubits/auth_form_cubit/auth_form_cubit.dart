import 'dart:io';

import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit() : super(const AuthFormState());

  void toggleShowPassword() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleShowConfirmPassword() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  void setAgreeToTerms(bool value) {
    emit(state.copyWith(agreeToTerms: value));
  }

  void setIdentityImage(File? image) {
    if (image == null) {
      emit(state.copyWith(clearIdentityImage: true));
    } else {
      emit(state.copyWith(identityImage: image));
    }
  }
}
