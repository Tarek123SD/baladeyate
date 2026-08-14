import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/admin/cubits/graves_cubit/graves_state.dart';
import 'package:baladeyate/features/admin/repo/admin_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GravesCubit extends Cubit<GravesState> {
  GravesCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const GravesInitial());

  final AdminRepository _adminRepository;

  Future<void> loadGraves() async {
    emit(const GravesLoading());
    try {
      final graves = await _adminRepository.getGraves();
      emit(GravesLoaded(graves: graves));
    } catch (error) {
      emit(GravesFailure(message: _messageFromError(error)));
    }
  }

  void updateQuery(String query) {
    final current = state;
    if (current is GravesLoaded) {
      emit(current.copyWith(query: query));
    }
  }

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'حدث خطأ غير متوقع',
    );
  }
}
