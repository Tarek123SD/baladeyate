import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/cemetery_reservation/cubits/grave_reservations_cubit/grave_reservations_state.dart';
import 'package:baladeyate/features/cemetery_reservation/repo/cemetery_reservation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraveReservationsCubit extends Cubit<GraveReservationsState> {
  GraveReservationsCubit({required CemeteryReservationRepository repository})
      : _repository = repository,
        super(const GraveReservationsInitial());

  final CemeteryReservationRepository _repository;

  Future<void> loadReservations() async {
    emit(const GraveReservationsLoading());
    try {
      final reservations = await _repository.getReservations();
      emit(GraveReservationsLoaded(reservations: reservations));
    } catch (error) {
      emit(
        GraveReservationsFailure(
          message: ApiResponseParser.toUserMessage(
            error,
            fallback: 'فشل تحميل طلبات الحجز',
          ),
        ),
      );
    }
  }

  Future<bool> cancelReservation(int id) async {
    final current = state;
    if (current is! GraveReservationsLoaded) return false;

    try {
      await _repository.cancelReservation(id);
      await loadReservations();
      return true;
    } catch (_) {
      return false;
    }
  }
}
