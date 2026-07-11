import 'package:equatable/equatable.dart';

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

final class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

final class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

final class PasswordResetOtpSent extends PasswordResetState {
  const PasswordResetOtpSent({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;

  @override
  List<Object?> get props => [email, message];
}

final class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class PasswordResetFailure extends PasswordResetState {
  const PasswordResetFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
