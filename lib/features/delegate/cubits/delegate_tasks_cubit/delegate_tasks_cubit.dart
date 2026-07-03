import 'package:baladeyate/features/delegate/cubits/delegate_tasks_cubit/delegate_tasks_state.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DelegateTasksCubit extends Cubit<DelegateTasksState> {
  DelegateTasksCubit({required DelegateRepository delegateRepository})
      : _delegateRepository = delegateRepository,
        super(const DelegateTasksInitial());

  final DelegateRepository _delegateRepository;

  Future<void> loadTasks() async {
    emit(const DelegateTasksLoading());
    try {
      final tasks = await _delegateRepository.getMyTasks();
      emit(DelegateTasksLoaded(tasks: tasks));
    } catch (error) {
      emit(DelegateTasksFailure(message: _messageFromError(error)));
    }
  }

  Future<DelegateTask?> loadTaskDetail(int id) async {
    try {
      return await _delegateRepository.getMyTaskById(id);
    } catch (error) {
      emit(DelegateTasksFailure(message: _messageFromError(error)));
      return null;
    }
  }

  Future<bool> updateTaskStatus({
    required int id,
    required String status,
  }) async {
    final current = state;
    if (current is DelegateTasksLoaded) {
      emit(current.copyWith(isUpdating: true));
    }

    try {
      final updated = await _delegateRepository.updateMyTaskStatus(
        id: id,
        status: status,
      );

      if (current is DelegateTasksLoaded) {
        final tasks = current.tasks
            .map((task) => task.id == id ? updated : task)
            .toList();
        emit(DelegateTasksLoaded(tasks: tasks));
      } else {
        await loadTasks();
      }
      return true;
    } catch (error) {
      if (current is DelegateTasksLoaded) {
        emit(current.copyWith(isUpdating: false));
      }
      emit(DelegateTasksFailure(message: _messageFromError(error)));
      return false;
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
