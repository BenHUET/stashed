import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:stashed_api/src/converters/server_task.dart';
import 'package:stashed_api/stashed_api.dart';

class WebsocketConnectionFailed implements Exception {}

class WebsocketVaultSubscriptionFailed implements Exception {}

class WebsocketVaultDeleted implements Exception {}

class TaskParseFailed implements Exception {
  final Object innerError;
  final List<Object?>? args;

  const TaskParseFailed({required this.innerError, required this.args});
}

enum StashedWebsocketClientStatus { disconnected, connecting, connected }

class StashedWebsocketClient {
  final Logger _logger;
  final Uri address;
  final String vaultId;
  late HubConnection _hubConnection;

  final _taskStreamController = BehaviorSubject<ServerTask>();
  final _statusStreamController = BehaviorSubject<StashedWebsocketClientStatus>.seeded(StashedWebsocketClientStatus.disconnected);

  StashedWebsocketClient({required this.address, required this.vaultId}) : _logger = Logger("Vault $vaultId") {
    _hubConnection = createHub();
  }

  HubConnection createHub() {
    final hub = HubConnectionBuilder().withUrl('$address/queue', options: HttpConnectionOptions(logger: _logger)).configureLogging(_logger).build();
    hub.on("ReceiveTask", _onTask);
    hub.on("ReceiveVaultDeletionNotification", _onVaultDeleted);
    hub.onclose(_onClose);
    hub.onreconnecting(_onReconnecting);
    hub.onreconnected(_onReconnected);
    return hub;
  }

  Stream<ServerTask> getTask() => _taskStreamController.asBroadcastStream();
  Stream<StashedWebsocketClientStatus> getStatus() => _statusStreamController.asBroadcastStream();

  Future<void> connect() async {
    if (_hubConnection.state == HubConnectionState.Connected || _hubConnection.state == HubConnectionState.Connecting || _hubConnection.state == HubConnectionState.Reconnecting) {
      return;
    }

    // Sometimes get stuck in the `Disconnecting` state and this prevents connecting
    // No way to force the state back to `Disonnected` so we spawn a fresh new hub
    if (_hubConnection.state == HubConnectionState.Disconnecting) {
      _hubConnection = createHub();
    }

    try {
      _statusStreamController.add(StashedWebsocketClientStatus.connecting);
      await _hubConnection.start();

      await _subscribeToVault();

      _statusStreamController.add(StashedWebsocketClientStatus.connected);
    } on WebsocketVaultSubscriptionFailed catch (e, s) {
      await _hubConnection.stop();
      _statusStreamController.addError(e, s);
    } catch (e, s) {
      await _hubConnection.stop();
      _statusStreamController.addError(WebsocketConnectionFailed(), s);
    }
  }

  Future<void> disconnect() async {
    _hubConnection.stop();
    _statusStreamController.add(StashedWebsocketClientStatus.disconnected);
  }

  Future<void> _subscribeToVault() async {
    var subscriptionResult = await _hubConnection.invoke("SubscribeToVault", args: [vaultId]) as bool;
    if (!subscriptionResult) {
      throw WebsocketVaultSubscriptionFailed();
    }
  }

  void _onClose({Exception? error}) async {
    _statusStreamController.add(StashedWebsocketClientStatus.disconnected);
  }

  void _onReconnecting({Exception? error}) {
    _statusStreamController.add(StashedWebsocketClientStatus.connecting);
  }

  void _onReconnected({String? connectionId}) async {
    try {
      await _subscribeToVault();
      _statusStreamController.add(StashedWebsocketClientStatus.connected);
    } on WebsocketVaultSubscriptionFailed catch (e, s) {
      await _hubConnection.stop();
      _statusStreamController.addError(e, s);
    }
  }

  void _onTask(List<Object?>? args) {
    if (args == null) {
      return;
    }

    try {
      final json = args[0] as Map<String, dynamic>;
      final task = const ServerTaskJsonConverter().fromJson(json);
      _taskStreamController.add(task);
    } catch (e) {
      _taskStreamController.addError(TaskParseFailed(innerError: e, args: args));
    }
  }

  void _onVaultDeleted(List<Object?>? args) async {
    _statusStreamController.addError(WebsocketVaultDeleted());
    await _hubConnection.stop();
  }

  void dispose() async {
    await _hubConnection.stop();
  }
}
