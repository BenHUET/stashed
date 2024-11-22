import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/app/app.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:vaults_repository/vaults_repository.dart';

class NewVaultPage extends StatelessWidget {
  final Server server;

  const NewVaultPage({required this.server, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewVaultCubit.add(vaultsRepository: context.read<VaultsRepository>(), server: server),
      child: const _VaultForm(),
    );
  }
}

class EditVaultPage extends StatelessWidget {
  final Server server;
  final Vault toEdit;

  const EditVaultPage({required this.server, required this.toEdit, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewVaultCubit.edit(vaultsRepository: context.read<VaultsRepository>(), server: server, vault: toEdit),
      child: const _VaultForm(),
    );
  }
}

class _VaultForm extends StatelessWidget {
  const _VaultForm();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocConsumer<NewVaultCubit, NewVaultState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.commonErrorMessage,
                style: TextStyle(
                  color: theme.colorScheme.onError,
                ),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = context.read<NewVaultCubit>();

        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.inputLabelTitle,
                errorText: switch (state.label.displayError) {
                  LabelValidationError.empty => l10n.inputErrorEmpty,
                  LabelValidationError.tooLong => l10n.inputErrorTooLong(state.label.maxSize),
                  _ => null,
                },
              ),
              enabled: !state.status.isInProgressOrSuccess,
              onChanged: (value) => cubit.onLabelChanged(value),
              initialValue: state.label.value,
            ),
            const SizedBox(height: spacingHeight),
            DropdownMenu<VaultKind>(
              enabled: !state.status.isInProgressOrSuccess && !cubit.isEdition,
              label: Text(l10n.inputVaultTypeTitle),
              initialSelection: state.vaultType.value,
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: [
                DropdownMenuEntry<VaultKind>(value: VaultKind.file, label: l10n.inputVaultTypeFileVault),
              ],
              onSelected: (type) => cubit.onVaultTypeChanged(type),
              errorText: switch (state.vaultType.displayError) {
                VaultTypeValidationError.empty => l10n.inputErrorEmpty,
                _ => null,
              },
            ),
            cubit.server.isLocalhost && state.vaultType.value == VaultKind.file
                ? Column(
                    children: [
                      FolderPicker(
                        enabled: !state.status.isInProgressOrSuccess && !cubit.isEdition,
                        initialValue: state.fileVaultDatabaseDirectory.value,
                        label: l10n.inputDatabaseDirectoryTitle,
                        errorText: switch (state.fileVaultDatabaseDirectory.displayError) {
                          PathValidationError.empty => l10n.inputErrorEmpty,
                          PathValidationError.malformed => l10n.inputErrorMalformed,
                          _ => null,
                        },
                        onPicked: (value) => cubit.onDatabaseDirectoryChanged(value),
                      ),
                      const SizedBox(height: spacingHeight),
                    ],
                  )
                : const SizedBox(height: spacingHeight),
            DropdownMenu<StorageKind>(
              enabled: !state.status.isInProgressOrSuccess && !cubit.isEdition,
              label: Text(l10n.inputStorageTypeTitle),
              initialSelection: state.storageType.value,
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: [
                DropdownMenuEntry<StorageKind>(value: StorageKind.local, label: l10n.inputStorageTypeLocalStorage),
              ],
              onSelected: (type) => cubit.onStorageTypeChanged(type),
              errorText: switch (state.storageType.displayError) {
                StorageTypeValidationError.empty => l10n.inputErrorEmpty,
                _ => null,
              },
            ),
            cubit.server.isLocalhost && state.storageType.value == StorageKind.local
                ? Column(
                    children: [
                      FolderPicker(
                        enabled: !state.status.isInProgressOrSuccess && !cubit.isEdition,
                        initialValue: state.localStorageFilesDirectory.value,
                        label: l10n.inputFilesDirectoryTitle,
                        errorText: switch (state.localStorageFilesDirectory.displayError) {
                          PathValidationError.empty => l10n.inputErrorEmpty,
                          PathValidationError.malformed => l10n.inputErrorMalformed,
                          _ => null,
                        },
                        onPicked: (value) => cubit.onFilesDirectoryChanged(value),
                      ),
                      const SizedBox(height: spacingHeight),
                    ],
                  )
                : const SizedBox(height: spacingHeight),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: state.status.isInProgressOrSuccess || !state.isValid
                    ? null
                    : () async {
                        await cubit.submitForm();
                      },
                child: Text(l10n.commonSave),
              ),
            ),
            state.status.isInProgress ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator()) : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
