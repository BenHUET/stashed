import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/converters/storage.dart';
import 'package:stashed_api/stashed_api.dart';

part '../_generated/models/file_vault.g.dart';

@JsonSerializable(createToJson: false)
class FileVault extends Vault {
  final String? databaseDirectory;

  const FileVault({required super.id, required super.label, super.storage, required this.databaseDirectory});

  factory FileVault.fromJson(Map<String, dynamic> json) => _$FileVaultFromJson(json);

  @override
  List<Object?> get props => [...super.props, databaseDirectory];
}
