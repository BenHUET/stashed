import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/converters/uint8_list_json_converter.dart';
import 'package:stashed_api/stashed_api.dart';

part '../_generated/models/image.g.dart';

@JsonSerializable(createToJson: false)
class Image extends Media {
  final int width;
  final int height;

  const Image({
    required super.sha256,
    required super.md5,
    required super.mimeType,
    super.filename,
    required super.size,
    required super.content,
    required this.width,
    required this.height,
  });

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
