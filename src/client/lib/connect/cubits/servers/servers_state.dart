part of 'servers_cubit.dart';

enum ServersStatus { initial, loading, success, failure }

class ServersState extends Equatable {
  final ServersStatus status;
  final List<Server> servers;

  const ServersState({
    this.status = ServersStatus.initial,
    this.servers = const [],
  });

  @override
  List<Object?> get props => [status, servers];

  ServersState copyWith({ServersStatus? status, List<Server>? servers}) {
    return ServersState(
      status: status ?? this.status,
      servers: servers ?? this.servers,
    );
  }
}
