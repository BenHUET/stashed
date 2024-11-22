import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/dtos/create_file_vault_request.dart';
import 'package:stashed_api/src/dtos/create_local_storage_request.dart';

part '../_generated/dtos/create_vault_request.g.dart';

@JsonSerializable(createFactory: false)
class CreateVaultRequestDTO {
  final CreateFileVaultRequestDTO? fileVault;
  final CreateLocalStorageRequestDTO? localStorage;

  const CreateVaultRequestDTO({this.fileVault, this.localStorage});

  CreateVaultRequestDTO copyWith({
    CreateFileVaultRequestDTO? fileVault,
    CreateLocalStorageRequestDTO? localStorage,
  }) {
    return CreateVaultRequestDTO(
      fileVault: fileVault ?? this.fileVault,
      localStorage: localStorage ?? this.localStorage,
    );
  }

  Map<String, dynamic> toJson() => _$CreateVaultRequestDTOToJson(this);
}
