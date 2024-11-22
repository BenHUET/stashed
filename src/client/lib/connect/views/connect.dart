import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/l10n/l10n.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServersCubit(serversRepository: context.read<ServersRepository>())..getServers(),
      child: const _ConnectView(),
    );
  }
}

class _ConnectView extends StatelessWidget {
  const _ConnectView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextIconButton(
              icon: Icons.add_outlined,
              text: l10n.connectNewServer,
              onPressed: () async {
                await showDialog<Server>(
                  context: context,
                  builder: (BuildContext _) {
                    return Dialog(
                      clipBehavior: Clip.hardEdge,
                      child: ModalContainer(
                        title: l10n.connectNewServerModalTitle,
                        child: const NewServerPage(),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: BlocBuilder<ServersCubit, ServersState>(
                builder: (context, state) {
                  return ListView(
                    addAutomaticKeepAlives: true,
                    children: state.servers.map(
                      (server) {
                        return ServerCard(
                          key: Key(server.id),
                          server: server,
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
