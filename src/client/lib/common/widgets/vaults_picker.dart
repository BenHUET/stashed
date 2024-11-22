import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:vaults_repository/vaults_repository.dart';

class VaultsPicker extends StatelessWidget {
  const VaultsPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultsPickerCubit, VaultsPickerState>(
      builder: (context, state) {
        var cubit = context.read<VaultsPickerCubit>();
        var l10n = context.l10n;
        var theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IntrinsicWidth(
            stepWidth: 50,
            child: Container(
              constraints: const BoxConstraints(minWidth: 150),
              child: InputDecorator(
                decoration: InputDecoration(
                  label: Text(l10n.vaultsPickerTitle),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  runSpacing: 5,
                  spacing: 5,
                  children: state.vaults.isNotEmpty
                      ? state.vaults.map(
                          (vault) {
                            return FilterChip(
                              showCheckmark: false,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: vault.selectionStatus == VaultSelectionStatus.selected ? Colors.white : Colors.black,
                              ),
                              label: Text(vault.label),
                              selected: vault.selectionStatus == VaultSelectionStatus.selected,
                              onSelected: (selected) {
                                if (selected) {
                                  cubit.selectVault(vault);
                                } else {
                                  cubit.unselectVault(vault);
                                }
                              },
                            );
                          },
                        ).toList()
                      : [
                          Center(
                            child: Text(
                              l10n.vaultsPickerNoVaultMessage,
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
