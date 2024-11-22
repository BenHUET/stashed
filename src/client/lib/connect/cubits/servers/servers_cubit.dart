import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:servers_repository/servers_repository.dart';

part 'servers_state.dart';

class ServersCubit extends Cubit<ServersState> {
  final ServersRepository _serversRepository;

  ServersCubit({required ServersRepository serversRepository})
      : _serversRepository = serversRepository,
        super(const ServersState());

  void getServers() {
    emit(state.copyWith(status: ServersStatus.loading));

    _serversRepository.getServers().listen(
      (servers) {
        emit(state.copyWith(status: ServersStatus.success, servers: servers));
      },
      onError: (_, __) => state.copyWith(status: ServersStatus.failure),
    );
  }
}
