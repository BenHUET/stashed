import 'package:stashed_api/stashed_api.dart' as api;
import 'package:tasks_repository/tasks_repository.dart';

class ServerTask<T> extends Task {
  final ServerTaskType type;
  final String? vaultId;
  T? result;

  ServerTask._({
    required super.id,
    super.error,
    required super.createdAt,
    super.startedAt,
    super.finishedAt,
    required super.status,
    super.dependsOn,
    super.requiredBy,
    required this.type,
    this.vaultId,
    this.result,
  });

  factory ServerTask.fromAPIModel({required api.ServerTask model, Task? dependsOn, List<Task> requiredBy = const []}) {
    return ServerTask._(
      type: model.type,
      id: model.id,
      error: model.error,
      createdAt: model.createdAt,
      startedAt: model.startedAt,
      finishedAt: model.finishedAt,
      status: TaskStatus.getByValue(model.status),
      dependsOn: dependsOn,
      vaultId: model.vaultId,
      result: model.result,
    );
  }

  factory ServerTask.placeholder({required String id, required Task dependsOn}) {
    return ServerTask._(
      type: ServerTaskType.placeholder,
      id: id,
      createdAt: DateTime.now(),
      status: TaskStatus.created,
      dependsOn: dependsOn,
    );
  }

  @override
  List<Object?> get props => [...super.props, vaultId, result];
}
