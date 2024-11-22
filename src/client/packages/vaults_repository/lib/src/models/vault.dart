import 'package:equatable/equatable.dart';
import 'package:stashed_api/stashed_api.dart' as api;
import 'package:vaults_repository/vaults_repository.dart';

enum VaultConnectionStatus { disabled, enabling, enabled }

enum VaultSelectionStatus { selected, unselected }

abstract class Vault extends Equatable {
  final Uri address;
  final String id;
  final String label;
  final api.Storage? storage;
  final VaultConnectionStatus connectionStatus;
  final VaultSelectionStatus selectionStatus;

  const Vault({
    required this.address,
    required this.id,
    required this.label,
    this.storage,
    required this.connectionStatus,
    required this.selectionStatus,
  });

  factory Vault.fromAPIModel({
    required api.Vault model,
    required VaultConnectionStatus connectionStatus,
    required VaultSelectionStatus selectionStatus,
    required Uri address,
  }) {
    if (model is api.FileVault) {
      return FileVault.fromAPIModel(model: model, connectionStatus: connectionStatus, selectionStatus: selectionStatus, address: address);
    } else {
      throw UnimplementedError();
    }
  }

  Vault copyWith({VaultConnectionStatus? connectionStatus, VaultSelectionStatus? selectionStatus});

  @override
  List<Object?> get props => [id, address, storage, label, connectionStatus, selectionStatus];
}
