import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:stashed/tasks/cubits/task/task_cubit.dart';
import 'package:tasks_repository/tasks_repository.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key(task.id),
      create: (context) => TaskCubit(
        tasksRepository: context.read<TasksRepository>(),
        task: task,
      ),
      child: task is ClientTask ? const _ClientTaskCardView() : const _ServerTaskCardView(),
    );
  }
}

class _ClientTaskCardView extends StatelessWidget {
  const _ClientTaskCardView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        var task = state.task as ClientTask;
        return Card(
          child: ExpansionTile(
            title: switch (task.runtimeType) {
              const (ClientTaskImport) => Text(l10n.clientTaskImportTitle((task as ClientTaskImport).file, (task).vaultLabel)),
              _ => throw UnimplementedError(),
            },
            leading: _TaskIcon(status: task.status),
            children: task.requiredBy
                .map(
                  (t) => TaskCard(
                    task: t,
                    key: Key(t.id),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _ServerTaskCardView extends StatelessWidget {
  const _ServerTaskCardView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        var task = state.task as ServerTask;
        return Card(
          child: ListTile(
            title: switch (task.type) {
              ServerTaskType.placeholder => Text(l10n.serverTaskTypePlaceholder),
              ServerTaskType.mediaImport => Text(l10n.serverTaskTypeMediaImport),
              ServerTaskType.generateThumbnail => Text(l10n.serverTaskTypeGenerateThumbnail),
            },
            leading: _TaskIcon(status: state.task.status),
          ),
        );
      },
    );
  }
}

class _TaskIcon extends StatelessWidget {
  final TaskStatus status;

  const _TaskIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      TaskStatus.created => const BackgroundIcon(icon: Icons.add_outlined, color: Colors.grey),
      TaskStatus.queued => const BackgroundIcon(icon: Icons.pending_outlined, color: Colors.grey),
      TaskStatus.running => const BackgroundIcon(icon: Icons.hourglass_bottom_outlined, color: Colors.blueAccent),
      TaskStatus.completed => const BackgroundIcon(icon: Icons.done_all_outlined, color: Colors.green),
      TaskStatus.failed => const BackgroundIcon(icon: Icons.error_outline_outlined, color: Colors.red),
      TaskStatus.ignored => const BackgroundIcon(icon: Icons.hide_source_outlined, color: Colors.grey),
      TaskStatus.canceled => const BackgroundIcon(icon: Icons.cancel_outlined, color: Colors.grey),
      TaskStatus.partiallyFailed => const BackgroundIcon(icon: Icons.warning_amber_rounded, color: Colors.orange),
    };
  }
}
