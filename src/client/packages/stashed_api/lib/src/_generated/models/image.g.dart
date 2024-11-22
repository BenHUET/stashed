// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      sha256: json['sha256'] as String,
      md5: json['md5'] as String,
      mimeType: json['mimeType'] as String,
      filename: json['filename'] as String?,
      size: json['size'] as int,
      content:
          const Uint8ListJsonConverter().fromJson(json['content'] as String?),
      width: json['width'] as int,
      height: json['height'] as int,
    );
