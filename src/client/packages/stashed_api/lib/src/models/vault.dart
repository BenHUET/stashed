import 'package:equatable/equatable.dart';
import 'package:stashed_api/src/converters/storage.dart';
import 'package:stashed_api/stashed_api.dart';

abstract class Vault extends Equatable {
  final String id;
  final String label;
  @StorageJsonConverter()
  final Storage? storage;

  const Vault({
    required this.id,
    required this.label,
    this.storage,
  });

  @override
  List<Object?> get props => [id, label, storage];
}
