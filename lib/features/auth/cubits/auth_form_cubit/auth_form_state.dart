import 'dart:io';

import 'package:equatable/equatable.dart';

class AuthFormState extends Equatable {
  const AuthFormState({
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.agreeToTerms = false,
    this.identityImage,
  });

  final bool showPassword;
  final bool showConfirmPassword;
  final bool agreeToTerms;
  final File? identityImage;

  AuthFormState copyWith({
    bool? showPassword,
    bool? showConfirmPassword,
    bool? agreeToTerms,
    File? identityImage,
    bool clearIdentityImage = false,
  }) {
    return AuthFormState(
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      identityImage:
          clearIdentityImage ? null : (identityImage ?? this.identityImage),
    );
  }

  @override
  List<Object?> get props => [
        showPassword,
        showConfirmPassword,
        agreeToTerms,
        identityImage,
      ];
}
