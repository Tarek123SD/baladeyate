import 'dart:io';

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
  const ProfileLoaded({
    required this.household,
    this.selectedTab = 0,
    this.identityImage,
    this.showResubmitForm = false,
  });

  final Household household;
  final int selectedTab;
  final File? identityImage;
  final bool showResubmitForm;

  ProfileLoaded copyWith({
    Household? household,
    int? selectedTab,
    File? identityImage,
    bool clearIdentityImage = false,
    bool? showResubmitForm,
  }) {
    return ProfileLoaded(
      household: household ?? this.household,
      selectedTab: selectedTab ?? this.selectedTab,
      identityImage:
          clearIdentityImage ? null : (identityImage ?? this.identityImage),
      showResubmitForm: showResubmitForm ?? this.showResubmitForm,
    );
  }

  @override
  List<Object?> get props =>
      [household, selectedTab, identityImage, showResubmitForm];
}

final class ProfileVerificationDraft extends ProfileState {
  const ProfileVerificationDraft({this.identityImage});

  final File? identityImage;

  ProfileVerificationDraft copyWith({
    File? identityImage,
    bool clearIdentityImage = false,
  }) {
    return ProfileVerificationDraft(
      identityImage:
          clearIdentityImage ? null : (identityImage ?? this.identityImage),
    );
  }

  @override
  List<Object?> get props => [identityImage];
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
