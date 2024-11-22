part of 'vaults_picker_cubit.dart';

class VaultsPickerState extends Equatable {
  final List<Vault> vaults;

  List<Vault> get selectedVaults => vaults.where((v) => v.selectionStatus == VaultSelectionStatus.selected).toList();

  const VaultsPickerState({this.vaults = const []});

  VaultsPickerState copyWith({List<Vault>? vaults, List<Vault>? selectedVaults}) {
    return VaultsPickerState(
      vaults: vaults ?? this.vaults,
    );
  }

  @override
  List<Object?> get props => [vaults];
}
