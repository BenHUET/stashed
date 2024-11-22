import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_api/settings_api.dart';
import 'package:stashed_api/stashed_api.dart' as api;
import 'package:vaults_repository/vaults_repository.dart';

class FetchVaultsException implements Exception {
  final Object innerError;
  final Uri address;

  const FetchVaultsException({required this.innerError, required this.address});
}

abstract class VaultException implements Exception {
  final Object innerError;
  final Uri address;
  final String vaultId;

  const VaultException({required this.innerError, required this.address, required this.vaultId});
}

class VaultConnectionFailed extends VaultException {
  const VaultConnectionFailed({required super.innerError, required super.address, required super.vaultId});
}

class VaultSubscriptionFailed extends VaultException {
  const VaultSubscriptionFailed({required super.innerError, required super.address, required super.vaultId});
}

class VaultDeleted extends VaultException {
  const VaultDeleted({required super.innerError, required super.address, required super.vaultId});
}

class VaultsRepository {
  final api.StashedApiClient _stashedApiClient;
  final api.StashedWebsocketClientFactory _websocketFactory;
  final SettingsApi _settingsApi;

  final _vaultsStreamController = BehaviorSubject<List<Vault>>.seeded(const []);

  List<Vault> get enabledVaults => _vaultsStreamController.value.where((e) => e.connectionStatus == VaultConnectionStatus.enabled).toList();

  List<Vault> get selectedVaults => _vaultsStreamController.value.where((e) => e.selectionStatus == VaultSelectionStatus.selected).toList();

  VaultsRepository({
    required api.StashedApiClient stashedApiClient,
    required api.StashedWebsocketClientFactory websocketFactory,
    required SettingsApi settingsApi,
  })  : _stashedApiClient = stashedApiClient,
        _websocketFactory = websocketFactory,
        _settingsApi = settingsApi;

  Stream<List<Vault>> getVaults() => _vaultsStreamController.asBroadcastStream();

  Stream<List<Vault>> getServerVaults(Uri address) => _vaultsStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Vault>, List<Vault>>.fromHandlers(
          handleData: (data, sink) {
            sink.add(data.where((e) => e.address == address).toList());
          },
          handleError: (error, stackTrace, sink) {
            if (error is FetchVaultsException && error.address == address) {
              sink.addError(error.innerError, stackTrace);
            }
          },
        ),
      );

  Stream<Vault> getVault(String vaultId) => _vaultsStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Vault>, Vault>.fromHandlers(
          handleData: (data, sink) {
            final result = data.firstWhereOrNull((e) => e.id == vaultId);
            if (result != null) {
              sink.add(result);
            }
          },
          handleError: (error, stackTrace, sink) {
            if (error is VaultException && error.vaultId == vaultId) {
              sink.addError(error);
            }
          },
        ),
      );

  Stream<List<Vault>> getEnabledVaults() => _vaultsStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Vault>, List<Vault>>.fromHandlers(
          handleData: (data, sink) {
            final results = data.where((e) => e.connectionStatus == VaultConnectionStatus.enabled).toList();
            sink.add(results);
          },
          handleError: (error, stackTrace, sink) {
            // ignore errors
          },
        ),
      );

  Stream<List<Vault>> getSelectedVaults() => _vaultsStreamController.asBroadcastStream().transform(
        StreamTransformer<List<Vault>, List<Vault>>.fromHandlers(
          handleData: (data, sink) {
            final results = data.where((e) => e.selectionStatus == VaultSelectionStatus.selected).toList();
            sink.add(results);
          },
          handleError: (error, stackTrace, sink) {
            // ignore errors
          },
        ),
      );

  Future<void> enableVault(Uri address, Vault vault) async {
    final websocket = await _websocketFactory.getClient(address, vault.id);

    websocket.getStatus().listen(
      (apiStatus) {
        final vaults = [..._vaultsStreamController.value];

        final index = vaults.indexWhere((e) => e.id == vault.id);
        if (index == -1) {
          return;
        }

        final newConnectionStatus = switch (apiStatus) {
          api.StashedWebsocketClientStatus.disconnected => VaultConnectionStatus.disabled,
          api.StashedWebsocketClientStatus.connecting => VaultConnectionStatus.enabling,
          api.StashedWebsocketClientStatus.connected => VaultConnectionStatus.enabled,
        };

        final newVault = vaults[index].copyWith(connectionStatus: newConnectionStatus);
        vaults[index] = newVault;

        _vaultsStreamController.add(vaults);
      },
    ).onError(
      (error) {
        if (error is api.WebsocketVaultSubscriptionFailed) {
          _vaultsStreamController.addError(VaultSubscriptionFailed(innerError: error, address: address, vaultId: vault.id));
        } else if (error is api.WebsocketVaultDeleted) {
          _vaultsStreamController.addError(VaultDeleted(innerError: error, address: address, vaultId: vault.id));
        } else {
          _vaultsStreamController.addError(VaultConnectionFailed(innerError: error, address: address, vaultId: vault.id));
        }
      },
    );

    await websocket.connect();

    await _settingsApi.saveSetting(_getSettingKeyForVaultStatus(vault.id), jsonEncode(true));
  }

  Future<void> disableVault(Uri address, Vault vault) async {
    _updateVault(vault.copyWith(selectionStatus: VaultSelectionStatus.unselected));
    final websocket = await _websocketFactory.getClient(address, vault.id);
    await websocket.disconnect();
    await _settingsApi.saveSetting(_getSettingKeyForVaultStatus(vault.id), jsonEncode(false));
  }

  void selectVault(Vault vault) {
    final newVault = vault.copyWith(selectionStatus: VaultSelectionStatus.selected);
    _updateVault(newVault);
  }

  void unselectVault(Vault vault) {
    final newVault = vault.copyWith(selectionStatus: VaultSelectionStatus.unselected);
    _updateVault(newVault);
  }

  Future<void> fetchVaults(Uri address) async {
    try {
      final apiResults = await _stashedApiClient.getVaults(address);
      final currentVaults = [..._vaultsStreamController.value];

      final newVaults = <Vault>[];
      for (var result in apiResults) {
        final existing = currentVaults.where((e) => e.id == result.id).firstOrNull;
        final connectionStatus = existing?.connectionStatus ?? VaultConnectionStatus.disabled;
        final selectionStatus = existing?.selectionStatus ?? VaultSelectionStatus.unselected;
        final newVault = Vault.fromAPIModel(model: result, connectionStatus: connectionStatus, selectionStatus: selectionStatus, address: address);
        newVaults.add(newVault);
      }

      _vaultsStreamController.add(newVaults);

      // Check from settings if this vault should be enabled
      for (var vault in newVaults) {
        if (vault.connectionStatus == VaultConnectionStatus.disabled) {
          final json = await _settingsApi.getSetting(_getSettingKeyForVaultStatus(vault.id));
          if (json != null) {
            final bool shouldEnable = jsonDecode(json);
            if (shouldEnable) {
              await enableVault(address, vault);
            }
          }
        }
      }
    } catch (e) {
      clearVaults(address);
      _vaultsStreamController.addError(FetchVaultsException(innerError: e, address: address));
    }
  }

  Future<void> clearVaults(Uri address) async {
    final currentVaults = [..._vaultsStreamController.value];

    for (var vault in currentVaults.where((e) => e.address == address)) {
      final websocket = await _websocketFactory.getClient(address, vault.id);
      await websocket.disconnect();
    }

    final newVaults = currentVaults.where((e) => e.address != address).toList();
    _vaultsStreamController.add(newVaults);
  }

  Future<void> createVault(Uri address, api.CreateVaultRequestBuilder builder) async {
    await _stashedApiClient.createVault(address, builder);
    fetchVaults(address);
  }

  Future<void> editVault(Uri address, String vaultId, String label) async {
    await _stashedApiClient.editVault(address, vaultId, label);
    fetchVaults(address);
  }

  Future<void> deleteVault(Uri address, Vault vault) async {
    await _stashedApiClient.deleteVault(address, vault.id);
    fetchVaults(address);
  }

  void _updateVault(Vault vault) {
    final vaults = [..._vaultsStreamController.value];

    final index = vaults.indexWhere((e) => e.id == vault.id);
    if (index == -1) {
      return;
    }

    vaults[index] = vault;
    _vaultsStreamController.add(vaults);
  }

  String _getSettingKeyForVaultStatus(String vaultId) => "vault_enabled_$vaultId";
}
