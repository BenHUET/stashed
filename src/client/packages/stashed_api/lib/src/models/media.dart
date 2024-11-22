import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:stashed_api/src/converters/uint8_list_json_converter.dart';

abstract class Media extends Equatable {
  final String sha256;
  final String md5;
  final String mimeType;
  final String? filename;
  final int size;
  @Uint8ListJsonConverter()
  final Uint8List? content;

  const Media({
    required this.sha256,
    required this.md5,
    required this.mimeType,
    this.filename,
    required this.size,
    this.content,
  });

  @override
  List<Object?> get props => [sha256, mimeType, filename, content == null];
}
