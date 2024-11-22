import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart' as vaults_repository show VaultConnectionStatus;
import 'package:vaults_repository/vaults_repository.dart' hide VaultConnectionStatus;

part 'vault_state.dart';

class VaultCubit extends Cubit<VaultState> {
  final VaultsRepository _vaultsRepository;
  final TasksRepository _tasksRepository;
  final Server server;
  Vault _vault;

  VaultCubit({
    required VaultsRepository vaultsRepository,
    required TasksRepository tasksRepository,
    required this.server,
    required Vault vault,
  })  : _vaultsRepository = vaultsRepository,
        _tasksRepository = tasksRepository,
        _vault = vault,
        super(VaultState(vault: vault)) {
    _vaultsRepository.getVault(_vault.id).listen(
      (v) {
        if (state.status == VaultStatus.failed) {
          return;
        }

        var newStatus = switch (v.connectionStatus) {
          vaults_repository.VaultConnectionStatus.disabled => VaultStatus.disabled,
          vaults_repository.VaultConnectionStatus.enabling => VaultStatus.connecting,
          vaults_repository.VaultConnectionStatus.enabled => VaultStatus.enabled,
        };
        emit(state.copyWith(vault: v, status: newStatus));
        _vault = v;
      },
    ).onError(
      (error) {
        emit(state.copyWith(status: VaultStatus.failed, error: error));
      },
    );
  }

  Future<void> enableVault() async {
    emit(state.copyWith(status: VaultStatus.connecting));

    try {
      await _vaultsRepository.enableVault(server.address, _vault);
      await _tasksRepository.enableVault(server.address, _vault.id);
      emit(state.copyWith(status: VaultStatus.enabled));
    } catch (e) {
      emit(state.copyWith(status: VaultStatus.failed, error: e));
    }
  }

  Future<void> disableVault() async {
    await _vaultsRepository.disableVault(server.address, _vault);
    await _tasksRepository.disableVault(server.address, _vault.id);
    emit(state.copyWith(status: VaultStatus.disabled));
  }

  Future<void> deleteVault() async {
    await _vaultsRepository.deleteVault(server.address, _vault);
  }
}
