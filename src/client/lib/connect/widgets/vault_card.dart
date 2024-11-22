import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart' hide VaultConnectionStatus;

class VaultCard extends StatelessWidget {
  final Server server;
  final Vault vault;

  const VaultCard({required this.server, required this.vault, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: Key(vault.id),
      create: (context) => VaultCubit(
        vaultsRepository: context.read<VaultsRepository>(),
        tasksRepository: context.read<TasksRepository>(),
        server: server,
        vault: vault,
      ),
      child: const _VaultCardView(),
    );
  }
}

class _VaultCardView extends StatelessWidget {
  const _VaultCardView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocBuilder<VaultCubit, VaultState>(
      builder: (context, state) {
        var cubit = context.read<VaultCubit>();
        return Card(
          child: ListTile(
            title: Text(state.vault.label),
            subtitle: state.status == VaultStatus.failed && state.error != null
                ? Text(
                    switch (state.error!) {
                      VaultConnectionFailed() => l10n.connectVaultConnectFailed,
                      VaultSubscriptionFailed() => l10n.connectVaultSubscriptionFailed,
                      VaultDeleted() => l10n.connectVaultDeleted,
                      _ => l10n.commonErrorMessage,
                    },
                    style: TextStyle(color: theme.colorScheme.error),
                  )
                : null,
            leading: Container(
              constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: switch (state.status) {
                  VaultStatus.disabled => Colors.grey,
                  VaultStatus.connecting => Colors.orange,
                  VaultStatus.enabled => Colors.green,
                  VaultStatus.failed => Colors.red,
                },
              ),
            ),
            trailing: Wrap(
              children: [
                state.status == VaultStatus.disabled || state.status == VaultStatus.failed
                    ? TextIconButton(
                        icon: Icons.cloud_sync_outlined,
                        text: l10n.commonEnable,
                        onPressed: !state.deleted
                            ? () async {
                                await context.read<VaultCubit>().enableVault();
                              }
                            : null,
                      )
                    : TextIconButton(
                        icon: Icons.cloud_off_outlined,
                        text: l10n.commonDisable,
                        onPressed: !state.deleted
                            ? () async {
                                await context.read<VaultCubit>().disableVault();
                              }
                            : null,
                      ),
                TextIconButton(
                  icon: Icons.edit_outlined,
                  text: l10n.commonEdit,
                  onPressed: !state.deleted
                      ? () async {
                          await showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                clipBehavior: Clip.hardEdge,
                                child: ModalContainer(
                                  title: l10n.connectEditVaultModalTitle,
                                  subtitle: cubit.server.address.toString(),
                                  child: EditVaultPage(server: cubit.server, toEdit: state.vault),
                                ),
                              );
                            },
                          );
                        }
                      : null,
                ),
                TextIconButton(
                  icon: Icons.delete_outlined,
                  text: l10n.commonRemove,
                  isDanger: true,
                  onPressed: !state.deleted
                      ? () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(l10n.connectRemoveVaultDialogTitle),
                              content: Text(l10n.connectRemoveVaultDialogMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  child: Text(l10n.connectRemoveVaultDialogCancel),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                  onPressed: () => context.pop(true),
                                  child: Text(l10n.connectRemoveVaultDialogConfirm),
                                ),
                              ],
                            ),
                          );

                          if (result != null && result) {
                            try {
                              await cubit.deleteVault();
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.connectVaultRemoveFailed,
                                    style: TextStyle(
                                      color: theme.colorScheme.onError,
                                    ),
                                  ),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
