import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stashed_api/stashed_api.dart' as api;
import 'package:tasks_repository/tasks_repository.dart';

// TODO : this repository is messy. Find a way to make ClientTask and ServerTask immutable without tanking perfs
// Also properly split data and business logic
class TasksRepository {
  final api.StashedWebsocketClientFactory _websocketFactory;
  final Map<String, StreamSubscription<api.ServerTask>> _subscriptions = {};
  final _queue = Queue<ClientTask>();

  TasksRepository({
    required api.StashedWebsocketClientFactory websocketFactory,
  }) : _websocketFactory = websocketFactory;

  final _tasksStreamController = BehaviorSubject<List<Task>>.seeded(const []);

  Stream<List<Task>> getTasks() => _tasksStreamController.asBroadcastStream();

  Stream<Task> getTask(String taskId) => _tasksStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Task>, Task>.fromHandlers(
          handleData: (data, sink) {
            final result = data.firstWhereOrNull((e) => e.id == taskId);
            if (result != null) {
              sink.add(result);
            }
          },
          handleError: (error, stackTrace, sink) {},
        ),
      );

  Future<void> enableVault(Uri address, String vaultId) async {
    final websocket = await _websocketFactory.getClient(address, vaultId);

    // Already enabled
    if (_subscriptions.containsKey(vaultId)) {
      return;
    }

    _subscriptions[vaultId] = websocket.getTask().listen(
      (apiTask) {
        // Convert the task to this layer model
        final serverTask = ServerTask.fromAPIModel(model: apiTask);

        // Resolve/update dependencies
        if (apiTask.dependsOnId != null) {
          final dependsOn = [..._tasksStreamController.value].firstWhere((t) => t.id == apiTask.dependsOnId);
          serverTask.dependsOn = dependsOn;

          final index = dependsOn.requiredBy.indexWhere((t) => t.id == serverTask.id);
          if (index >= 0) {
            serverTask.dependsOn!.requiredBy[index] = serverTask;
          } else {
            serverTask.dependsOn!.requiredBy.add(serverTask);
          }
        }

        _addServerTask(serverTask);
      },
    )..onError(
        (e) {
          if (e is api.TaskParseFailed) {
            _tasksStreamController.addError(e);
          }
        },
      );
  }

  Future<void> disableVault(Uri address, String vaultId) async {
    _subscriptions[vaultId]?.cancel();
  }

  void queue(ClientTask clientTask) {
    clientTask.status = TaskStatus.queued;
    _queue.addLast(clientTask);

    final tasks = [..._tasksStreamController.value];
    tasks.add(clientTask);
    _tasksStreamController.add(tasks);
  }

  ClientTask? dequeue() {
    if (_queue.isEmpty) {
      return null;
    }

    return _queue.removeFirst();
  }

  void updateClientTask({
    required ClientTask clientTask,
    TaskStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    Object? error,
    Set<String>? results,
  }) {
    if (status != null) clientTask.status = status;
    if (startedAt != null) clientTask.startedAt = startedAt;
    if (finishedAt != null) clientTask.finishedAt = finishedAt;
    if (error != null) clientTask.error = error;

    // Build placeholders for the expected server tasks resulting from it
    // Sometimes, the actual server task will be received before we had time to create the placeholder
    // so we check for an actual task before adding the placeholder
    if (results != null) {
      final List<ServerTask> serverTasks = <ServerTask>[];
      for (var id in results) {
        final existingServerTask = _tasksStreamController.value.firstWhereOrNull((e) => e.id == id);

        if (existingServerTask == null) {
          final placeholder = ServerTask.placeholder(id: id, dependsOn: clientTask);
          serverTasks.add(placeholder);
          _addServerTask(placeholder);
        } else {
          existingServerTask.dependsOn = clientTask;
          serverTasks.add(existingServerTask as ServerTask);
        }
      }
      clientTask.requiredBy = serverTasks;
      _updateClientTaskStatus(clientTask);
    }

    _tasksStreamController.add([..._tasksStreamController.value]);
  }

  void _addServerTask(ServerTask serverTask) {
    // Grab all tasks from the stream
    final tasks = [..._tasksStreamController.value];

    // Look for an existing task with the same id
    final existingTask = tasks.firstWhereOrNull((e) => e is ServerTask && e.id == serverTask.id) as ServerTask?;

    // If the incoming task is new
    if (existingTask == null) {
      tasks.add(serverTask);
    }
    // If a task with this id exists already, make sure it's an actual update by comparing their statuses
    // If that's the case, update it
    else if (serverTask.status.value >= existingTask.status.value) {
      existingTask.status = serverTask.status;
      existingTask.startedAt = serverTask.createdAt;
      existingTask.error = serverTask.error;
      existingTask.finishedAt = serverTask.finishedAt;
      existingTask.result = serverTask.result;
    } else {
      return;
    }

    // Find any ClientTask depending on this task and update its status
    var clientTask = tasks.firstWhereOrNull((t1) => t1 is ClientTask && t1.requiredBy.any((t2) => t2.id == serverTask.id));
    if (clientTask != null) {
      _updateClientTaskStatus(clientTask as ClientTask);
    }

    _tasksStreamController.add(tasks);
  }

  void _updateClientTaskStatus(ClientTask task) {
    if (task.requiredBy.every((t) => t.status == TaskStatus.created)) {
      task.status = TaskStatus.created;
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.queued)) {
      task.status = TaskStatus.queued;
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.running)) {
      task.status = TaskStatus.running;
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.completed || t.status == TaskStatus.ignored)) {
      task.status = TaskStatus.completed;
      task.finishedAt = DateTime.now();
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.failed || t.status == TaskStatus.ignored)) {
      task.status = TaskStatus.failed;
      task.finishedAt = DateTime.now();
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.ignored)) {
      task.status = TaskStatus.ignored;
      task.finishedAt = DateTime.now();
    } else if (task.requiredBy.every((t) => t.status == TaskStatus.canceled || t.status == TaskStatus.ignored)) {
      task.status = TaskStatus.canceled;
      task.finishedAt = DateTime.now();
    } else if (task.requiredBy.any((t) => t.status.value <= TaskStatus.running.value)) {
      task.status = TaskStatus.running;
    } else if (task.requiredBy.any((t) => t.status == TaskStatus.failed)) {
      task.status = TaskStatus.partiallyFailed;
      task.finishedAt = DateTime.now();
    }

    _tasksStreamController.add([..._tasksStreamController.value]);
  }
}
