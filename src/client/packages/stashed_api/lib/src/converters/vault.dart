import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/stashed_api.dart';

class VaultJsonConverter extends JsonConverter<Vault, Map<String, dynamic>> {
  const VaultJsonConverter();

  @override
  Vault fromJson(Map<String, dynamic> json) {
    if (json.containsKey('databaseDirectory')) {
      return FileVault.fromJson(json);
    }

    throw ArgumentError();
  }

  @override
  Map<String, dynamic> toJson(Vault object) {
    throw UnimplementedError();
  }
}
