import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/stashed_api.dart';

class StorageJsonConverter extends JsonConverter<Storage, Map<String, dynamic>> {
  const StorageJsonConverter();

  @override
  Storage fromJson(Map<String, dynamic> json) {
    if (json.containsKey('filesDirectory')) {
      return LocalStorage.fromJson(json);
    }

    throw ArgumentError();
  }

  @override
  Map<String, dynamic> toJson(Storage object) {
    throw UnimplementedError();
  }
}
