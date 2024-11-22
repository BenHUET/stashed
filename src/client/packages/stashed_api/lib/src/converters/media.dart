import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/stashed_api.dart';

class MediaJsonConverter extends JsonConverter<Media, Map<String, dynamic>> {
  const MediaJsonConverter();

  @override
  Media fromJson(Map<String, dynamic> json) {
    // Image
    // TODO : only supports images for now
    if (true) {
      return Image.fromJson(json);
    }

    throw ArgumentError();
  }

  @override
  Map<String, dynamic> toJson(Media object) {
    throw UnimplementedError();
  }
}
