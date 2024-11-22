import 'package:stashed_api/stashed_api.dart' as api;
import 'package:vaults_repository/vaults_repository.dart';

class FileVault extends Vault {
  final String? databaseDirectory;

  const FileVault({
    required super.address,
    required super.id,
    required super.label,
    super.storage,
    required this.databaseDirectory,
    required super.connectionStatus,
    required super.selectionStatus,
  });

  FileVault.fromAPIModel({
    required api.FileVault model,
    required VaultConnectionStatus connectionStatus,
    required VaultSelectionStatus selectionStatus,
    required Uri address,
  }) : this(
          address: address,
          id: model.id,
          label: model.label,
          connectionStatus: connectionStatus,
          selectionStatus: selectionStatus,
          storage: model.storage,
          databaseDirectory: model.databaseDirectory,
        );

  @override
  FileVault copyWith({
    VaultConnectionStatus? connectionStatus,
    VaultSelectionStatus? selectionStatus,
  }) {
    return FileVault(
      address: address,
      id: id,
      label: label,
      storage: storage,
      databaseDirectory: databaseDirectory,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      selectionStatus: selectionStatus ?? this.selectionStatus,
    );
  }
}
