import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/connect/widgets/vault_card.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:vaults_repository/vaults_repository.dart';

class ServerCard extends StatefulWidget {
  final Server server;

  const ServerCard({required this.server, super.key});

  @override
  State<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<ServerCard> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      key: Key("${widget.server.id}${widget.server.address.toString()}"),
      create: (context) => ServerCubit(
        serversRepository: context.read<ServersRepository>(),
        vaultsRepository: context.read<VaultsRepository>(),
        server: widget.server,
      )..refresh(),
      child: const _ServerCardView(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ServerCardView extends StatelessWidget {
  const _ServerCardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerCubit, ServerState>(
      builder: (context, state) {
        var l10n = context.l10n;
        var theme = Theme.of(context);
        var cubit = context.read<ServerCubit>();
        return Card(
          child: ExpansionTile(
            maintainState: true,
            initiallyExpanded: true,
            childrenPadding: const EdgeInsets.fromLTRB(48, 0, 0, 0),
            leading: switch (state.vaultsStatus) {
              VaultsStatus.initial => const Icon(Icons.dns_outlined),
              VaultsStatus.loading => Container(constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16), child: const CircularProgressIndicator()),
              VaultsStatus.success => const Icon(Icons.dns_outlined),
              VaultsStatus.unreachable || VaultsStatus.unauthorized => const Icon(Icons.cancel_outlined),
            },
            title: Text(state.server.label),
            subtitle: switch (state.vaultsStatus) {
              VaultsStatus.loading => Text(l10n.commonConnecting),
              VaultsStatus.success => Text(l10n.connectFetchVaultsSuccess(state.vaults.length)),
              VaultsStatus.unreachable => Text(l10n.connectFetchVaultsFailed, style: TextStyle(color: theme.colorScheme.error)),
              VaultsStatus.unauthorized => Text(l10n.connectFetchVaultsNotAuthorized, style: TextStyle(color: theme.colorScheme.error)),
              VaultsStatus.initial => null,
            },
            trailing: Wrap(
              children: [
                state.vaultsStatus == VaultsStatus.success
                    ? IconButton(
                        icon: const Icon(Icons.add_outlined),
                        tooltip: l10n.connectNewVault,
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext _) {
                              return Dialog(
                                clipBehavior: Clip.hardEdge,
                                child: ModalContainer(
                                  title: l10n.connectNewVaultModalTitle,
                                  subtitle: state.server.address.toString(),
                                  child: NewVaultPage(server: state.server),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : const SizedBox.shrink(),
                state.vaultsStatus == VaultsStatus.success
                    ? IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: l10n.commonAdmin,
                        onPressed: state.vaultsStatus.isDone
                            ? () {
                                context.read<ServerCubit>().refresh();
                              }
                            : null,
                      )
                    : const SizedBox.shrink(),
                IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  tooltip: l10n.commonRefresh,
                  onPressed: state.vaultsStatus.isDone
                      ? () {
                          context.read<ServerCubit>().refresh();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.commonEdit,
                  onPressed: () async {
                    await showDialog<Server>(
                      context: context,
                      builder: (BuildContext _) {
                        return Dialog(
                          clipBehavior: Clip.hardEdge,
                          child: ModalContainer(
                            title: l10n.connectEditServerModalTitle,
                            child: EditServerPage(toEdit: state.server),
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outlined),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: l10n.commonRemove,
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(l10n.connectRemoveServerDialogTitle),
                        content: Text(l10n.connectRemoveServerDialogMessage),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(false),
                            child: Text(l10n.connectRemoveServerDialogCancel),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            onPressed: () => context.pop(true),
                            child: Text(l10n.connectRemoveServerDialogConfirm),
                          ),
                        ],
                      ),
                    );

                    if (result != null && result) {
                      await cubit.removeServer();
                    }
                  },
                ),
              ],
            ),
            children: state.vaults.map(
              (vault) {
                return VaultCard(
                  key: Key(vault.id),
                  server: state.server,
                  vault: vault,
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}
