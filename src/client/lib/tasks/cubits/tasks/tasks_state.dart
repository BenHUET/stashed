part of 'tasks_cubit.dart';

class TasksState extends Equatable {
  final List<Task> tasks;

  const TasksState({
    this.tasks = const [],
  });

  TasksState copyWith({
    List<Task>? tasks,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object> get props => [tasks];
}
