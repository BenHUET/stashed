part of 'server_cubit.dart';

enum VaultsStatus { initial, loading, success, unreachable, unauthorized }

extension VaultStatusExtensions on VaultsStatus {
  bool get isDone => this == VaultsStatus.success || this == VaultsStatus.unreachable || this == VaultsStatus.unauthorized;
}

class ServerState extends Equatable {
  final Server server;
  final VaultsStatus vaultsStatus;
  final List<Vault> vaults;

  const ServerState({required this.server, this.vaultsStatus = VaultsStatus.initial, this.vaults = const []});

  ServerState copyWith({
    Server? server,
    VaultsStatus? vaultsStatus,
    List<Vault>? vaults,
  }) {
    return ServerState(
      server: server ?? this.server,
      vaultsStatus: vaultsStatus ?? this.vaultsStatus,
      vaults: vaults ?? this.vaults,
    );
  }

  @override
  List<Object?> get props => [server, vaultsStatus, vaults];
}
