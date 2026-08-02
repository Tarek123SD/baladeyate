import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_state.dart';
import 'package:baladeyate/features/donations/repo/donations_repository.dart';

class DonateCubit extends Cubit<DonateState> {
  DonateCubit({required DonationsRepository donationsRepository})
      : _donationsRepository = donationsRepository,
        super(const DonateInitial());

  final DonationsRepository _donationsRepository;

  Future<void> submitDonation({
    required int id,
    required num amount,
    required File? receiptImage,
  }) async {
    if (amount <= 0) {
      emit(const DonateFailure(message: 'يرجى إدخال مبلغ تبرع صحيح'));
      return;
    }

    if (receiptImage == null) {
      emit(const DonateFailure(
        message: 'يرجى إرفاق صورة إيصال التحويل/الدفع قبل التأكيد',
      ));
      return;
    }

    emit(const DonateLoading());
    try {
      await _donationsRepository.submitDonation(
        id: id,
        amount: amount,
        receiptImage: receiptImage,
      );
      emit(const DonateSuccess());
    } catch (error) {
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      emit(DonateFailure(
        message: errorMessage.isNotEmpty ? errorMessage : 'فشل إرسال التبرع',
      ));
    }
  }

  void reset() {
    emit(const DonateInitial());
  }
}
