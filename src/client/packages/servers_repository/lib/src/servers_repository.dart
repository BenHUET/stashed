import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:settings_api/settings_api.dart';
import 'package:stashed_api/stashed_api.dart';

const String _settingKeyServers = "servers";

class ServersRepository {
  final StashedApiClient _stashedApiClient;
  final SettingsApi _settingsApi;

  final _serversStreamController = BehaviorSubject<List<Server>>.seeded(const []);

  ServersRepository({
    required StashedApiClient stashedApiClient,
    required SettingsApi settingsApi,
  })  : _stashedApiClient = stashedApiClient,
        _settingsApi = settingsApi;

  Future<void> init() async {
    final content = await _settingsApi.getSetting(_settingKeyServers);

    if (content == null) {
      return;
    }

    final Iterable list = jsonDecode(content);
    final List<Server> servers = List<Server>.from(list.map((model) => Server.fromJson(model)));

    _serversStreamController.add(servers);
  }

  Stream<List<Server>> getServers() => _serversStreamController.asBroadcastStream();

  Stream<Server> getServer(String id) => _serversStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Server>, Server>.fromHandlers(
          handleData: (data, sink) {
            final result = data.where((element) => element.id == id).firstOrNull;
            if (result != null) {
              sink.add(result);
            }
          },
          handleError: (error, stackTrace, sink) {},
        ),
      );

  Server getServerByAddress(Uri address) {
    final server = _serversStreamController.value.firstWhere((s) => s.address == address);
    return server;
  }

  Future<void> saveServer(Server server) async {
    final servers = [..._serversStreamController.value];

    final index = servers.indexWhere((s) => s.id == server.id);
    if (index >= 0) {
      servers[index] = server;
    } else {
      servers.add(server);
    }

    await _settingsApi.saveSetting(_settingKeyServers, jsonEncode(servers));
    _serversStreamController.add(servers);
  }

  Future<void> removeServer(Server server) async {
    final servers = [..._serversStreamController.value];

    servers.removeWhere((s) => s.id == server.id);

    await _settingsApi.saveSetting(_settingKeyServers, jsonEncode(servers));
    _serversStreamController.add(servers);
  }

  Future<void> fetchServerManifest(Server server) async {
    final manifest = await _stashedApiClient.getManifest(server.address);

    final servers = [..._serversStreamController.value];

    final index = servers.indexWhere((s) => s.id == server.id);
    if (index >= 0) {
      servers[index] = servers[index].copyWith(manifest: () => manifest);
    }

    _serversStreamController.add(servers);
  }
}
