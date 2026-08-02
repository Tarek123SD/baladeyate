import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:baladeyate/features/donations/repo/donations_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DonationsCubit extends Cubit<DonationsState> {
  DonationsCubit({required DonationsRepository donationsRepository})
      : _donationsRepository = donationsRepository,
        super(const DonationsInitial());

  final DonationsRepository _donationsRepository;

  Future<void> fetchDonations() async {
    if (state is! DonationsLoaded) {
      emit(const DonationsLoading());
    }
    try {
      final cases = await _donationsRepository.getCases(limit: 20);
      emit(DonationsLoaded(cases: cases));
    } catch (error) {
      if (state is! DonationsLoaded) {
        emit(DonationsFailure(message: _messageFromError(error)));
      }
    }
  }

  Future<void> loadCases() => fetchDonations();

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
