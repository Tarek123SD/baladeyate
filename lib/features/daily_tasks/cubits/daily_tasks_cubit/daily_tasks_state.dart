import 'package:baladeyate/features/daily_tasks/utils/delegate_task_display.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DailyTasksState extends Equatable {
  const DailyTasksState({
    this.pins = const [],
    this.delegateTasks = const [],
    this.isLoadingPins = false,
    this.isLoadingTasks = false,
    this.isUpdatingTask = false,
    this.isLocating = false,
    this.isAddPinMode = false,
    this.selectedPinId,
    this.currentPosition,
    this.locationMessage,
    this.mapType = MapType.normal,
    this.errorMessage,
  });

  final List<SurveyPin> pins;
  final List<DelegateTask> delegateTasks;
  final bool isLoadingPins;
  final bool isLoadingTasks;
  final bool isUpdatingTask;
  final bool isLocating;
  final bool isAddPinMode;
  final String? selectedPinId;
  final LatLng? currentPosition;
  final String? locationMessage;
  final MapType mapType;
  final String? errorMessage;

  int get totalTasks => pins.length + delegateTasks.length;

  int get completedTasks =>
      pins.where((pin) => pin.status == SurveyPinStatus.completed).length +
      completedDelegateTasks(delegateTasks).length;

  int get inProgressTasks =>
      pins.where((pin) => pin.status == SurveyPinStatus.inProgress).length +
      activeDelegateTasks(delegateTasks)
          .where((task) => task.isInProgress)
          .length;

  List<DelegateTask> get activeAssignedTasks =>
      activeDelegateTasks(delegateTasks);

  /// Filters [pins] by status. Pass null for all pins.
  List<SurveyPin> filteredPins(SurveyPinStatus? filter) {
    if (filter == null) return pins;
    return pins.where((pin) => pin.status == filter).toList();
  }

  String get achievementPercent {
    if (totalTasks == 0) return '0';
    return ((completedTasks / totalTasks) * 100).round().toString();
  }

  DailyTasksState copyWith({
    List<SurveyPin>? pins,
    List<DelegateTask>? delegateTasks,
    bool? isLoadingPins,
    bool? isLoadingTasks,
    bool? isUpdatingTask,
    bool? isLocating,
    bool? isAddPinMode,
    String? selectedPinId,
    bool clearSelectedPinId = false,
    LatLng? currentPosition,
    String? locationMessage,
    bool clearLocationMessage = false,
    MapType? mapType,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DailyTasksState(
      pins: pins ?? this.pins,
      delegateTasks: delegateTasks ?? this.delegateTasks,
      isLoadingPins: isLoadingPins ?? this.isLoadingPins,
      isLoadingTasks: isLoadingTasks ?? this.isLoadingTasks,
      isUpdatingTask: isUpdatingTask ?? this.isUpdatingTask,
      isLocating: isLocating ?? this.isLocating,
      isAddPinMode: isAddPinMode ?? this.isAddPinMode,
      selectedPinId:
          clearSelectedPinId ? null : (selectedPinId ?? this.selectedPinId),
      currentPosition: currentPosition ?? this.currentPosition,
      locationMessage: clearLocationMessage
          ? null
          : (locationMessage ?? this.locationMessage),
      mapType: mapType ?? this.mapType,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        pins,
        delegateTasks,
        isLoadingPins,
        isLoadingTasks,
        isUpdatingTask,
        isLocating,
        isAddPinMode,
        selectedPinId,
        currentPosition,
        locationMessage,
        mapType,
        errorMessage,
      ];
}
