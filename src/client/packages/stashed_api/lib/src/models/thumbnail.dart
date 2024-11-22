import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/converters/uint8_list_json_converter.dart';

part '../_generated/models/thumbnail.g.dart';

@JsonSerializable(createToJson: false)
class Thumbnail extends Equatable {
  final String originalSha256;
  final int size;
  @Uint8ListJsonConverter()
  final Uint8List? content;

  const Thumbnail({
    required this.originalSha256,
    required this.size,
    this.content,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => _$ThumbnailFromJson(json);

  @override
  List<Object?> get props => [originalSha256, size, content == null];
}
