import 'package:flutter/foundation.dart';
import 'package:media_repository/media_repository.dart';
import 'package:stashed_api/stashed_api.dart' as api;

class Image extends Media {
  final int width;
  final int height;

  const Image({
    required super.address,
    required super.vaultId,
    required super.sha256,
    required super.md5,
    required super.mimeType,
    super.filename,
    required super.size,
    required super.content,
    required super.thumbnail,
    required this.width,
    required this.height,
  });

  Image.fromAPIModel({
    required api.Image model,
    required Uri address,
    required String vaultId,
  }) : this(
          address: address,
          vaultId: vaultId,
          sha256: model.sha256,
          md5: model.md5,
          mimeType: model.mimeType,
          filename: model.filename,
          size: model.size,
          content: model.content,
          thumbnail: null,
          width: model.width,
          height: model.height,
        );

  @override
  Image copyWith({
    ValueGetter<Uint8List?>? content,
    ValueGetter<Uint8List?>? thumbnail,
  }) {
    return Image(
      address: address,
      vaultId: vaultId,
      sha256: sha256,
      md5: md5,
      mimeType: mimeType,
      filename: filename,
      size: size,
      content: content != null ? content() : this.content,
      thumbnail: thumbnail != null ? thumbnail() : this.thumbnail,
      width: width,
      height: height,
    );
  }

  @override
  List<Object?> get props => [...super.props, width, height];
}
