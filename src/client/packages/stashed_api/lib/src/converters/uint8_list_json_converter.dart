import "dart:convert";
import "dart:typed_data";

import "package:json_annotation/json_annotation.dart";

class Uint8ListJsonConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListJsonConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null) return null;
    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null) return null;
    return base64Encode(object);
  }
}
