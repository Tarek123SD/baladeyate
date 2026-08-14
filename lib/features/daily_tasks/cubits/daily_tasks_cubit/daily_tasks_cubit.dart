import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/repo/daily_tasks_repository.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DailyTasksCubit extends Cubit<DailyTasksState> {
  DailyTasksCubit({required DailyTasksRepository dailyTasksRepository})
      : _dailyTasksRepository = dailyTasksRepository,
        super(const DailyTasksState());

  final DailyTasksRepository _dailyTasksRepository;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait([loadPins(), loadTasks(), initLocation()]);
  }

  /// Forces a full reload of pins and tasks (e.g. after finishing a survey).
  Future<void> refreshDashboard() {
    return Future.wait([loadPins(), loadTasks()]);
  }

  /// Clears in-memory state on logout so the next session starts fresh.
  void clearSession() {
    _initialized = false;
    emit(const DailyTasksState());
  }

  Future<void> loadPins() async {
    emit(state.copyWith(isLoadingPins: true, clearErrorMessage: true));
    try {
      final pins = await _dailyTasksRepository.getMapPins();
      emit(state.copyWith(pins: pins, isLoadingPins: false));
    } catch (error) {
      emit(state.copyWith(
        isLoadingPins: false,
        errorMessage: _messageFromError(error),
      ));
    }
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(isLoadingTasks: true, clearErrorMessage: true));
    try {
      final tasks = await _dailyTasksRepository.getMyTasks();
      emit(state.copyWith(delegateTasks: tasks, isLoadingTasks: false));
    } catch (error) {
      emit(state.copyWith(
        isLoadingTasks: false,
        errorMessage: _messageFromError(error),
      ));
    }
  }

  Future<bool> updateTaskStatus({
    required int id,
    required String status,
  }) async {
    emit(state.copyWith(isUpdatingTask: true, clearErrorMessage: true));
    try {
      final updated = await _dailyTasksRepository.updateMyTaskStatus(
        id: id,
        status: status,
      );
      final tasks = state.delegateTasks
          .map((task) => task.id == id ? updated : task)
          .toList();
      emit(state.copyWith(
        delegateTasks: tasks,
        isUpdatingTask: false,
      ));
      return true;
    } catch (error) {
      emit(state.copyWith(
        isUpdatingTask: false,
        errorMessage: _messageFromError(error),
      ));
      return false;
    }
  }

  Future<void> initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(locationMessage: 'يرجى تفعيل خدمة الموقع'));
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        locationMessage: 'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق',
      ));
      await Geolocator.openAppSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      emit(state.copyWith(locationMessage: 'لم يتم منح إذن الموقع'));
      return;
    }

    await moveToCurrentLocation();
  }

  Future<LatLng?> moveToCurrentLocation() async {
    emit(state.copyWith(isLocating: true));
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        final latLng = LatLng(position.latitude, position.longitude);
        emit(state.copyWith(
          currentPosition: latLng,
          isLocating: false,
          clearLocationMessage: true,
        ));
        return latLng;
      }
    } catch (_) {}

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      emit(state.copyWith(
        currentPosition: latLng,
        isLocating: false,
        clearLocationMessage: true,
      ));
      return latLng;
    } catch (_) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 6),
          ),
        );
        final latLng = LatLng(position.latitude, position.longitude);
        emit(state.copyWith(
          currentPosition: latLng,
          isLocating: false,
          clearLocationMessage: true,
        ));
        return latLng;
      } catch (err) {
        emit(state.copyWith(
          isLocating: false,
          locationMessage: 'تعذر تحديد موقعك الحالي',
        ));
        return null;
      }
    }
  }

  void selectPin(String? pinId) {
    emit(
      pinId == null
          ? state.copyWith(clearSelectedPinId: true)
          : state.copyWith(selectedPinId: pinId, isAddPinMode: false),
    );
  }

  void setPinStatusFilter(SurveyPinStatus? filter) {
    final selectedId = state.selectedPinId;
    final keepSelection = selectedId == null ||
        filter == null ||
        state.pins.any((pin) => pin.id == selectedId && pin.status == filter);

    emit(state.copyWith(
      pinStatusFilter: filter,
      clearPinStatusFilter: filter == null,
      clearSelectedPinId: !keepSelection,
    ));
  }

  void toggleAddPinMode() {
    final enabling = !state.isAddPinMode;
    emit(state.copyWith(
      isAddPinMode: enabling,
      clearSelectedPinId: enabling,
    ));
  }

  void enableAddPinMode() {
    if (!state.isAddPinMode) {
      emit(state.copyWith(isAddPinMode: true, clearSelectedPinId: true));
    }
  }

  void toggleMapType() {
    emit(state.copyWith(
      mapType: state.mapType == MapType.normal
          ? MapType.hybrid
          : MapType.normal,
    ));
  }

  Future<SurveyPin> saveDraftPin({
    required String pinId,
    required double latitude,
    required double longitude,
  }) async {
    final draftPin = SurveyPin(
      id: pinId,
      latitude: latitude,
      longitude: longitude,
      status: SurveyPinStatus.inProgress,
      title: 'مسح جديد',
    );
    await _dailyTasksRepository.saveDraftPin(draftPin);
    return draftPin;
  }

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'حدث خطأ غير متوقع',
    );
  }
}
