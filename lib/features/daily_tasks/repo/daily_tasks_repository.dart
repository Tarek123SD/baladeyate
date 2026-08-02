import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';

/// Data access for daily tasks / delegate map dashboard.
///
/// Delegates persistence to [DelegateRepository] so survey and map data stay
/// in a single source of truth.
class DailyTasksRepository {
  DailyTasksRepository({required DelegateRepository delegateRepository})
      : _delegateRepository = delegateRepository;

  final DelegateRepository _delegateRepository;

  Future<List<SurveyPin>> getMapPins() => _delegateRepository.getMapPins();

  Future<List<DelegateTask>> getMyTasks() => _delegateRepository.getMyTasks();

  Future<DelegateTask> updateMyTaskStatus({
    required int id,
    required String status,
  }) {
    return _delegateRepository.updateMyTaskStatus(id: id, status: status);
  }

  Future<void> saveDraftPin(SurveyPin pin) =>
      _delegateRepository.saveDraftPin(pin);
}
