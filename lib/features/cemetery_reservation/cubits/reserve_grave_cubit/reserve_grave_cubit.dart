import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/reserve_grave_cubit/reserve_grave_state.dart';
import 'package:baladeyate/features/cemetery_reservation/repo/cemetery_reservation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReserveGraveCubit extends Cubit<ReserveGraveState> {
  ReserveGraveCubit({required CemeteryReservationRepository repository})
      : _repository = repository,
        super(const ReserveGraveInitial());

  final CemeteryReservationRepository _repository;

  Future<void> submit({
    required int graveId,
    required String deceasedName,
    String? notes,
  }) async {
    if (deceasedName.trim().isEmpty) {
      emit(const ReserveGraveFailure(message: 'يرجى إدخال اسم المتوفى'));
      return;
    }

    emit(const ReserveGraveLoading());
    try {
      await _repository.submitReservation(
        graveId: graveId,
        deceasedName: deceasedName,
        notes: notes,
      );
      emit(const ReserveGraveSuccess());
    } catch (error) {
      emit(
        ReserveGraveFailure(
          message: ApiResponseParser.toUserMessage(
            error,
            fallback: 'فشل إرسال طلب الحجز',
          ),
        ),
      );
    }
  }

  void reset() => emit(const ReserveGraveInitial());
}
