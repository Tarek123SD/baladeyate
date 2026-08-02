import 'dart:io';

import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';
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
    required this.user,
    this.selectedTab = 0,
    this.identityImage,
    this.showResubmitForm = false,
    this.household,
    this.householdMessage,
  });

  final User user;
  final int selectedTab;
  final File? identityImage;
  final bool showResubmitForm;
  final RegisteredHousehold? household;

  /// Soft message when household is unavailable (404 / not verified), not a hard failure.
  final String? householdMessage;

  ProfileLoaded copyWith({
    User? user,
    int? selectedTab,
    File? identityImage,
    bool clearIdentityImage = false,
    bool? showResubmitForm,
    RegisteredHousehold? household,
    bool clearHousehold = false,
    String? householdMessage,
    bool clearHouseholdMessage = false,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      selectedTab: selectedTab ?? this.selectedTab,
      identityImage:
          clearIdentityImage ? null : (identityImage ?? this.identityImage),
      showResubmitForm: showResubmitForm ?? this.showResubmitForm,
      household: clearHousehold ? null : (household ?? this.household),
      householdMessage: clearHouseholdMessage
          ? null
          : (householdMessage ?? this.householdMessage),
    );
  }

  @override
  List<Object?> get props => [
        user,
        selectedTab,
        identityImage,
        showResubmitForm,
        household,
        householdMessage,
      ];
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
