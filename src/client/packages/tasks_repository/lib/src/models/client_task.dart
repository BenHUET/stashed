import 'package:flutter/material.dart';
import 'package:tasks_repository/tasks_repository.dart';

abstract class ClientTask extends Task {
  final String vaultLabel;
  // An HTTP call which returns a list of server task ids
  final Future<Set<String>> Function() task;

  ClientTask({
    required super.id,
    super.error,
    required super.createdAt,
    super.startedAt,
    super.finishedAt,
    required super.status,
    super.dependsOn,
    super.requiredBy,
    required this.task,
    required this.vaultLabel,
  });

  @override
  List<Object?> get props => [...super.props, task];
}

class ClientTaskImport extends ClientTask {
  final String file;

  ClientTaskImport({
    required this.file,
    required super.vaultLabel,
    required super.task,
  }) : super(
          id: UniqueKey().toString(),
          createdAt: DateTime.now(),
          status: TaskStatus.created,
        );

  @override
  List<Object?> get props => [...super.props, file, vaultLabel];
}
