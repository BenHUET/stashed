import 'package:equatable/equatable.dart';
import 'package:tasks_repository/tasks_repository.dart';

abstract class Task extends Equatable {
  final String id;
  Object? error;
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? finishedAt;
  TaskStatus status;
  Task? dependsOn;
  List<Task> requiredBy;

  Task({
    required this.id,
    this.error,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    required this.status,
    this.dependsOn,
    List<Task>? requiredBy,
  }) : requiredBy = requiredBy ?? [];

  @override
  List<Object?> get props => [id, error, createdAt, startedAt, finishedAt, status];
}
