import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/connect/connect.dart';
import 'package:vaults_repository/vaults_repository.dart' hide VaultConnectionStatus;

part 'new_vault_state.dart';

class NewVaultCubit extends Cubit<NewVaultState> {
  final VaultsRepository _vaultsRepository;
  final Server server;
  final Vault? vault;

  bool get isEdition => vault != null;

  NewVaultCubit._({
    required VaultsRepository vaultsRepository,
    required this.server,
    this.vault,
    required NewVaultState state,
  })  : _vaultsRepository = vaultsRepository,
        super(state);

  NewVaultCubit.add({required VaultsRepository vaultsRepository, required Server server})
      : this._(
          vaultsRepository: vaultsRepository,
          server: server,
          vault: null,
          state: const NewVaultState(),
        );

  NewVaultCubit.edit({required VaultsRepository vaultsRepository, required Server server, required Vault vault})
      : this._(
          vaultsRepository: vaultsRepository,
          server: server,
          vault: vault,
          state: NewVaultState.fromVault(vault: vault),
        );

  bool validate({Label? label, VaultType? vaultType, StorageType? storageType, Path? fileVaultDatabaseDirectory, Path? localStorageFilesDirectory}) {
    return Formz.validate([
      label ?? state.label,
      vaultType ?? state.vaultType,
      storageType ?? state.storageType,
      fileVaultDatabaseDirectory ?? state.fileVaultDatabaseDirectory,
      localStorageFilesDirectory ?? state.localStorageFilesDirectory,
    ]);
  }

  void onLabelChanged(String value) {
    final label = Label.dirty(value);

    emit(
      state.copyWith(
        label: label.isValid ? Label.pure(value) : label,
        isValid: validate(label: label),
      ),
    );
  }

  void onVaultTypeChanged(VaultKind? value) {
    final vaultType = VaultType.dirty(value);

    emit(
      state.copyWith(
        vaultType: vaultType.isValid ? VaultType.pure(value) : vaultType,
        isValid: validate(vaultType: vaultType),
      ),
    );
  }

  void onStorageTypeChanged(StorageKind? value) {
    final storageType = StorageType.dirty(value);

    emit(
      state.copyWith(
        storageType: storageType.isValid ? StorageType.pure(value) : storageType,
        isValid: validate(storageType: storageType),
      ),
    );
  }

  void onDatabaseDirectoryChanged(String? value) {
    final fileVaultDatabaseDirectory = Path.dirty(value ?? '');

    emit(
      state.copyWith(
        fileVaultDatabaseDirectory: fileVaultDatabaseDirectory.isValid ? Path.pure(value ?? '') : fileVaultDatabaseDirectory,
        isValid: validate(fileVaultDatabaseDirectory: fileVaultDatabaseDirectory),
      ),
    );
  }

  void onFilesDirectoryChanged(String? value) {
    final localStorageFilesDirectory = Path.dirty(value ?? '');

    emit(
      state.copyWith(
        localStorageFilesDirectory: localStorageFilesDirectory.isValid ? Path.pure(value ?? '') : localStorageFilesDirectory,
        isValid: validate(localStorageFilesDirectory: localStorageFilesDirectory),
      ),
    );
  }

  Future<void> submitForm() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      if (!isEdition) {
        final builder = CreateVaultRequestBuilder();

        switch (state.vaultType.value) {
          case VaultKind.file:
            builder.withFileVault(label: state.label.value, databaseDirectory: state.fileVaultDatabaseDirectory.value);
          default:
            throw UnimplementedError();
        }

        switch (state.storageType.value) {
          case StorageKind.local:
            builder.withLocalStorage(filesDirectory: state.localStorageFilesDirectory.value);
          default:
            throw UnimplementedError();
        }

        await _vaultsRepository.createVault(server.address, builder);
      } else {
        await _vaultsRepository.editVault(server.address, vault!.id, state.label.value);
      }

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, error: e));
    }
  }
}
