import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TasksRepository _tasksRepository;
  StreamSubscription<Task>? _subscription;

  TaskCubit({required TasksRepository tasksRepository, required Task task})
      : _tasksRepository = tasksRepository,
        super(TaskState(task: task)) {
    _subscription = _tasksRepository.getTask(task.id).listen(
      (t) {
        emit(state.copyWith(task: t));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
