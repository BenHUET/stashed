import 'package:json_annotation/json_annotation.dart';

part '../_generated/dtos/create_file_vault_request.g.dart';

@JsonSerializable(createFactory: false)
class CreateFileVaultRequestDTO {
  final String label;
  final String? databaseDirectory;

  CreateFileVaultRequestDTO({required this.label, this.databaseDirectory});

  Map<String, dynamic> toJson() => _$CreateFileVaultRequestDTOToJson(this);
}
