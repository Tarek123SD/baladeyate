import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:equatable/equatable.dart';

sealed class DelegateTasksState extends Equatable {
  const DelegateTasksState();

  @override
  List<Object?> get props => [];
}

final class DelegateTasksInitial extends DelegateTasksState {
  const DelegateTasksInitial();
}

final class DelegateTasksLoading extends DelegateTasksState {
  const DelegateTasksLoading();
}

final class DelegateTasksLoaded extends DelegateTasksState {
  const DelegateTasksLoaded({
    required this.tasks,
    this.isUpdating = false,
  });

  final List<DelegateTask> tasks;
  final bool isUpdating;

  DelegateTasksLoaded copyWith({
    List<DelegateTask>? tasks,
    bool? isUpdating,
  }) {
    return DelegateTasksLoaded(
      tasks: tasks ?? this.tasks,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [tasks, isUpdating];
}

final class DelegateTasksFailure extends DelegateTasksState {
  const DelegateTasksFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
