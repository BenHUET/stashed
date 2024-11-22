import 'dart:async';

import 'package:tasks_repository/tasks_repository.dart';

enum TaskRunnerStatus { stopped, running }

class TaskRunner {
  final TasksRepository _tasksRepository;

  TaskRunnerStatus status = TaskRunnerStatus.stopped;

  TaskRunner({required TasksRepository tasksRepository}) : _tasksRepository = tasksRepository;

  void start() async {
    status = TaskRunnerStatus.running;

    while (true) {
      final task = _tasksRepository.dequeue();
      if (task != null) {
        await _processClientTask(task);
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> _processClientTask(ClientTask task) async {
    try {
      var serverTasksIds = await task.task();
      _tasksRepository.updateClientTask(
        clientTask: task,
        status: TaskStatus.running,
        results: serverTasksIds,
      );
    } catch (e) {
      _tasksRepository.updateClientTask(
        clientTask: task,
        status: TaskStatus.failed,
        startedAt: DateTime.now(),
        error: e,
      );
    }
  }
}
