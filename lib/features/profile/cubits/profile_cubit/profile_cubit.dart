import 'dart:io';

import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/features/profile/repo/citizen_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required CitizenRepository citizenRepository,
    required AuthCubit authCubit,
  })  : _citizenRepository = citizenRepository,
        _authCubit = authCubit,
        super(const ProfileInitial());

  final CitizenRepository _citizenRepository;
  final AuthCubit _authCubit;

  int get selectedTab {
    final current = state;
    if (current is ProfileLoaded) return current.selectedTab;
    return 0;
  }

  File? get identityImage {
    final current = state;
    if (current is ProfileLoaded) return current.identityImage;
    if (current is ProfileVerificationDraft) return current.identityImage;
    return null;
  }

  bool get showResubmitForm {
    final current = state;
    if (current is ProfileLoaded) return current.showResubmitForm;
    return false;
  }

  Future<void> loadProfile() async {
    final previousTab = selectedTab;
    final previousImage = identityImage;
    emit(const ProfileLoading());
    try {
      await _authCubit.refreshUser();
      final authState = _authCubit.state;
      if (authState is! AuthSuccess) {
        emit(const ProfileFailure(message: 'يجب تسجيل الدخول أولاً'));
        return;
      }

      RegisteredHousehold? household;
      String? householdMessage;
      try {
        household = await _citizenRepository.getMyHousehold();
        if (household == null) {
          householdMessage = 'لا يوجد سجل سكني مرتبط بحسابك بعد.';
        }
      } catch (error) {
        householdMessage = _messageFromError(error);
      }

      emit(ProfileLoaded(
        user: authState.user,
        selectedTab: previousTab,
        identityImage: previousImage,
        household: household,
        householdMessage: householdMessage,
      ));
    } catch (error) {
      emit(ProfileFailure(message: _messageFromError(error)));
    }
  }

  void selectTab(int index) {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(selectedTab: index));
    }
  }

  void setIdentityImage(File? image) {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(identityImage: image, clearIdentityImage: image == null));
    } else if (current is ProfileVerificationDraft) {
      emit(current.copyWith(identityImage: image, clearIdentityImage: image == null));
    } else {
      emit(ProfileVerificationDraft(identityImage: image));
    }
  }

  void setShowResubmitForm(bool value) {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(showResubmitForm: value));
    } else {
      final authState = _authCubit.state;
      if (authState is AuthSuccess) {
        emit(ProfileLoaded(
          user: authState.user,
          showResubmitForm: value,
        ));
      }
    }
  }

  Future<void> updatePhone(String phoneNumber) async {
    emit(const ProfileLoading());
    try {
      final user = await _citizenRepository.updateProfile(phoneNumber: phoneNumber);
      _authCubit.updateUser(user);
      emit(const ProfilePhoneUpdated());
    } catch (error) {
      emit(ProfileFailure(message: _messageFromError(error)));
    }
  }

  Future<void> verifyIdentity({
    required String nationalId,
    required File identityImage,
  }) async {
    emit(const ProfileLoading());
    try {
      final status = await _citizenRepository.verifyIdentity(
        nationalId: nationalId,
        identityImage: identityImage,
      );
      await _authCubit.applyVerificationStatus(status);
      emit(const ProfileVerificationSubmitted());
    } catch (error) {
      emit(ProfileFailure(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'حدث خطأ غير متوقع',
    );
  }
}
