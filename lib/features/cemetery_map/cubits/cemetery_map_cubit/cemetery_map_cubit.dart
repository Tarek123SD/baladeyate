import 'package:baladeyate/features/cemetery_map/cubits/cemetery_map_cubit/cemetery_map_state.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_map/repo/cemetery_map_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CemeteryMapCubit extends Cubit<CemeteryMapState> {
  CemeteryMapCubit({
    required CemeteryMapRepository cemeteryMapRepository,
    this.cemeteryId = GraveModel.defaultCemeteryId,
  })  : _cemeteryMapRepository = cemeteryMapRepository,
        super(const CemeteryMapState(isLoading: true));

  final CemeteryMapRepository _cemeteryMapRepository;
  final int cemeteryId;

  Future<void> loadGraves() async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final graves = await _cemeteryMapRepository.getGraves(
        cemeteryId: cemeteryId,
      );
      emit(
        state.copyWith(
          graves: List<GraveModel>.unmodifiable(graves),
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  void toggleAddingMode() {
    emit(
      state.copyWith(
        isAddingMode: !state.isAddingMode,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<bool> createGraveAt({
    required double x,
    required double y,
    double width = GraveModel.defaultGraveWidth,
    double height = GraveModel.defaultGraveHeight,
    String status = 'available',
    String? deceasedName,
  }) async {
    if (state.isSubmitting) return false;

    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final created = await _cemeteryMapRepository.createGrave(
        cemeteryId: cemeteryId,
        x: x,
        y: y,
        width: width,
        height: height,
        status: status,
        deceasedName: deceasedName,
      );

      emit(
        state.copyWith(
          graves: List<GraveModel>.unmodifiable([...state.graves, created]),
          isSubmitting: false,
          isAddingMode: false,
          successMessage: 'تمت إضافة القبر بنجاح',
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _messageFromError(error),
        ),
      );
      return false;
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
