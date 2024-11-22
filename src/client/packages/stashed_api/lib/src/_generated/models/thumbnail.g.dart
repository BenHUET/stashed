// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/thumbnail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thumbnail _$ThumbnailFromJson(Map<String, dynamic> json) => Thumbnail(
      originalSha256: json['originalSha256'] as String,
      size: json['size'] as int,
      content:
          const Uint8ListJsonConverter().fromJson(json['content'] as String?),
    );
