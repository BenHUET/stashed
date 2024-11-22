import 'package:stashed_api/stashed_api.dart';

class StashedWebsocketClientFactory {
  final Map<String, StashedWebsocketClient> _websockets = {};

  Future<StashedWebsocketClient> getClient(Uri address, String vaultId) async {
    if (!_websockets.containsKey(vaultId)) {
      final client = StashedWebsocketClient(address: address, vaultId: vaultId);
      _websockets[vaultId] = client;
    }

    return _websockets[vaultId]!;
  }
}
