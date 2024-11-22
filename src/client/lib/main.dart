import 'package:auth_repository/auth_repository.dart';
import 'package:beeapps_api/beeapps_api.dart';
import 'package:bloc/bloc.dart';
import 'package:cache_api/cache_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:media_repository/media_repository.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:settings_api/settings_api.dart';
import 'package:stashed/app/app.dart';
import 'package:stashed/task_runner/task_runner.dart';
import 'package:stashed_api/stashed_api.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message} ${record.error ?? ''}');
  });

  Bloc.observer = AppBlocObserver();

  await dotenv.load(fileName: "assets/.env");

  final dioStashed = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json; charset=UTF-8',
    ),
  );

  final dioBeeapps = Dio(
    BaseOptions(
      contentType: 'application/x-www-form-urlencoded',
      baseUrl: '${dotenv.env['AUTH_BASE_URL']}/realms/${dotenv.env['AUTH_REALM']}/protocol/openid-connect/',
    ),
  );

  const secureStorage = FlutterSecureStorage();

  final stashedApiClient = StashedApiClient(dio: dioStashed);

  final stashedWebsocketClientFactory = StashedWebsocketClientFactory();

  final settingsApi = SettingsApi();

  final cacheApi = CacheApiClient();

  final beeappsApiClient = BeeappsApiClient(dio: dioBeeapps);

  final serversRepository = ServersRepository(
    stashedApiClient: stashedApiClient,
    settingsApi: settingsApi,
  );

  final vaultsRepository = VaultsRepository(
    stashedApiClient: stashedApiClient,
    websocketFactory: stashedWebsocketClientFactory,
    settingsApi: settingsApi,
  );

  final tasksRepository = TasksRepository(
    websocketFactory: stashedWebsocketClientFactory,
  );

  final mediaRepository = MediaRepository(
    stashedApiClient: stashedApiClient,
    cacheApi: cacheApi,
  );

  final authRepository = AuthRepository(
    beeappsApiClient: beeappsApiClient,
    secureStorage: secureStorage,
  );

  final queriesRepository = QueriesRepository();

  dioStashed.interceptors.add(AppDioInterceptor(
    logger: Logger("HTTP"),
    authRepository: authRepository,
    serversRepository: serversRepository,
  ));

  TaskRunner(tasksRepository: tasksRepository).start();

  runApp(
    App(
      serversRepository: serversRepository,
      vaultsRepository: vaultsRepository,
      tasksRepository: tasksRepository,
      mediaRepository: mediaRepository,
      queriesRepository: queriesRepository,
      authRepository: authRepository,
    ),
  );
}
