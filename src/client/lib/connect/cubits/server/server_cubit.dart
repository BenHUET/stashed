import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

part 'server_state.dart';

class ServerCubit extends Cubit<ServerState> {
  Server _server;
  final ServersRepository _serversRepository;
  final VaultsRepository _vaultsRepository;
  StreamSubscription<Server>? _serverSubscription;
  StreamSubscription<List<Vault>>? _vaultsSubscription;

  ServerCubit({required ServersRepository serversRepository, required VaultsRepository vaultsRepository, required Server server})
      : _serversRepository = serversRepository,
        _vaultsRepository = vaultsRepository,
        _server = server,
        super(ServerState(server: server)) {
    _serverSubscription = _serversRepository.getServer(_server.id).listen(
      (s) {
        emit(state.copyWith(server: s));
        _server = s;
      },
    );

    _vaultsSubscription = _vaultsRepository.getServerVaults(_server.address).listen(
      (vaults) {
        emit(state.copyWith(vaults: vaults, vaultsStatus: VaultsStatus.success));
      },
    )..onError(
        (error) {
          var status = VaultsStatus.unreachable;
          if (error.response?.statusCode == 401) {
            status = VaultsStatus.unauthorized;
          }

          emit(state.copyWith(vaultsStatus: status));
        },
      );
  }

  Future<void> refresh() async {
    emit(state.copyWith(vaultsStatus: VaultsStatus.loading));
    await _serversRepository.fetchServerManifest(_server);
    await _vaultsRepository.fetchVaults(_server.address);
  }

  Future<void> removeServer() async {
    await _serversRepository.removeServer(_server);
  }

  @override
  Future<void> close() async {
    await _serverSubscription?.cancel();
    await _vaultsSubscription?.cancel();
    return super.close();
  }
}
