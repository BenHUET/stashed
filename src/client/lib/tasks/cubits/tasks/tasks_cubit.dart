import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks_repository/tasks_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _tasksRepository;

  TasksCubit({required TasksRepository tasksRepository})
      : _tasksRepository = tasksRepository,
        super(const TasksState()) {
    _tasksRepository.getTasks().listen((tasks) {
      final topLevelTasks = tasks.where((e) => e is ClientTask && e.dependsOn == null).toList();
      emit(state.copyWith(tasks: topLevelTasks));
    });
  }
}
