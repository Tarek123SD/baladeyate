import 'package:baladeyate/features/profile/models/household.dart';
import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.household});

  final Household household;

  @override
  List<Object?> get props => [household];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileVerificationSubmitted extends ProfileState {
  const ProfileVerificationSubmitted();
}

final class ProfilePhoneUpdated extends ProfileState {
  const ProfilePhoneUpdated();
}
