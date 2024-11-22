import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vaults_repository/vaults_repository.dart';

part 'vaults_picker_state.dart';

class VaultsPickerCubit extends Cubit<VaultsPickerState> {
  final VaultsRepository _vaultsRepository;

  VaultsPickerCubit({required VaultsRepository vaultsRepository})
      : _vaultsRepository = vaultsRepository,
        super(const VaultsPickerState()) {
    _vaultsRepository.getEnabledVaults().listen(
      (vaults) {
        emit(state.copyWith(vaults: vaults));
      },
    );
  }

  void selectVault(Vault vault) {
    _vaultsRepository.selectVault(vault);
  }

  void unselectVault(Vault vault) {
    _vaultsRepository.unselectVault(vault);
  }
}
