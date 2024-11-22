import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stashed/tasks/tasks.dart';
import 'package:tasks_repository/tasks_repository.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksCubit(tasksRepository: context.read<TasksRepository>()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return ListView(
          children: state.tasks
              .sortedBy<num>((t) => t.status.value)
              .reversed
              .map(
                (task) => TaskCard(
                  key: Key(task.id),
                  task: task,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
