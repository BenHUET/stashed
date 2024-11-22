part of 'vault_cubit.dart';

enum VaultStatus { disabled, connecting, enabled, failed }

class VaultState extends Equatable {
  final Vault vault;
  final VaultStatus status;
  final Object? error;
  bool get deleted => error != null && error is VaultDeleted;

  const VaultState({
    required this.vault,
    this.status = VaultStatus.disabled,
    this.error,
  });

  VaultState copyWith({
    Vault? vault,
    VaultStatus? status,
    Object? error,
  }) {
    return VaultState(
      vault: vault ?? this.vault,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [vault, status, error];
}
