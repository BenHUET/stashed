import 'package:equatable/equatable.dart';

enum ServerTaskType { placeholder, mediaImport, generateThumbnail }

class ServerTask<T> extends Equatable {
  final ServerTaskType type;
  final String id;
  final String? vaultId;
  final String? error;
  final String? dependsOnId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int status;
  final T? result;

  const ServerTask({
    required this.type,
    required this.id,
    this.vaultId,
    this.error,
    this.dependsOnId,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    required this.status,
    this.result,
  });

  @override
  List<Object?> get props => [type, id, vaultId, error, dependsOnId, createdAt, startedAt, finishedAt, status, result == null];
}
