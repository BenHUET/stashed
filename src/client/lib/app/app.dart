import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:media_repository/media_repository.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/app/router.dart';
import 'package:stashed/app/theme.dart';
import 'package:stashed/common/common.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

import 'scroll_behavior.dart';

export 'bloc_observer.dart';
export 'constants.dart';
export 'dio_interceptor.dart';

class App extends StatelessWidget {
  final ServersRepository serversRepository;
  final VaultsRepository vaultsRepository;
  final TasksRepository tasksRepository;
  final MediaRepository mediaRepository;
  final QueriesRepository queriesRepository;
  final AuthRepository authRepository;

  const App({
    required this.serversRepository,
    required this.vaultsRepository,
    required this.tasksRepository,
    required this.mediaRepository,
    required this.queriesRepository,
    required this.authRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: serversRepository),
        RepositoryProvider.value(value: vaultsRepository),
        RepositoryProvider.value(value: tasksRepository),
        RepositoryProvider.value(value: mediaRepository),
        RepositoryProvider.value(value: queriesRepository),
        RepositoryProvider.value(value: authRepository),
        BlocProvider(create: (_) => VaultsPickerCubit(vaultsRepository: vaultsRepository))
      ],
      child: MaterialApp.router(
        title: 'stashed',
        scrollBehavior: CustomScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        routerConfig: router,
      ),
    );
  }
}
