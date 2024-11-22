part of 'task_cubit.dart';

class TaskState extends Equatable {
  final Task task;

  const TaskState({required this.task});

  TaskState copyWith({
    Task? task,
  }) {
    return TaskState(
      task: task ?? this.task,
    );
  }

  @override
  List<Object?> get props => [task];
}
