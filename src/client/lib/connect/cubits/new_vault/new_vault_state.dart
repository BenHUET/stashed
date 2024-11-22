part of 'new_vault_cubit.dart';

class NewVaultState extends Equatable {
  final Label label;
  final VaultType vaultType;
  final StorageType storageType;
  final Path fileVaultDatabaseDirectory;
  final Path localStorageFilesDirectory;
  final FormzSubmissionStatus status;
  final bool isValid;
  final Object? error;

  const NewVaultState({
    this.label = const Label.pure(),
    this.vaultType = const VaultType.pure(),
    this.storageType = const StorageType.pure(),
    this.fileVaultDatabaseDirectory = const Path.pure(),
    this.localStorageFilesDirectory = const Path.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.error,
  });

  NewVaultState.fromVault({required Vault vault})
      : label = Label.pure(vault.label),
        vaultType = VaultType.pure(switch (vault.runtimeType) {
          FileVault => VaultKind.file,
          _ => throw UnimplementedError(),
        }),
        storageType = StorageType.pure(vault.storage != null ? StorageKind.local : throw UnimplementedError()),
        fileVaultDatabaseDirectory = Path.pure((vault as FileVault).databaseDirectory ?? ''),
        localStorageFilesDirectory = Path.pure((vault.storage as LocalStorage).filesDirectory ?? ''),
        status = FormzSubmissionStatus.initial,
        isValid = true,
        error = null;

  NewVaultState copyWith({
    Label? label,
    VaultType? vaultType,
    StorageType? storageType,
    Path? fileVaultDatabaseDirectory,
    Path? localStorageFilesDirectory,
    FormzSubmissionStatus? status,
    bool? isValid,
    Object? error,
  }) {
    return NewVaultState(
      label: label ?? this.label,
      vaultType: vaultType ?? this.vaultType,
      storageType: storageType ?? this.storageType,
      fileVaultDatabaseDirectory: fileVaultDatabaseDirectory ?? this.fileVaultDatabaseDirectory,
      localStorageFilesDirectory: localStorageFilesDirectory ?? this.localStorageFilesDirectory,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [label, vaultType, storageType, fileVaultDatabaseDirectory, localStorageFilesDirectory, status, isValid, error];
}
