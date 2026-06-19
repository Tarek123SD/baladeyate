import 'dart:io';

import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
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

  Future<void> loadHousehold() async {
    emit(const ProfileLoading());
    try {
      final household = await _citizenRepository.getMyHousehold();
      emit(ProfileLoaded(household: household));
    } catch (error) {
      emit(ProfileFailure(message: _messageFromError(error)));
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
      final user = await _citizenRepository.verifyIdentity(
        nationalId: nationalId,
        identityImage: identityImage,
      );
      _authCubit.updateUser(user);
      emit(const ProfileVerificationSubmitted());
    } catch (error) {
      emit(ProfileFailure(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
