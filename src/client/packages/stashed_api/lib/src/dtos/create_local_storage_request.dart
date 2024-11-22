import 'package:json_annotation/json_annotation.dart';

part '../_generated/dtos/create_local_storage_request.g.dart';

@JsonSerializable(createFactory: false)
class CreateLocalStorageRequestDTO {
  final String? filesDirectory;

  const CreateLocalStorageRequestDTO({this.filesDirectory});

  Map<String, dynamic> toJson() => _$CreateLocalStorageRequestDTOToJson(this);
}
