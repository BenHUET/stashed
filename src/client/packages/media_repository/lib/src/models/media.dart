import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:media_repository/media_repository.dart';
import 'package:stashed_api/stashed_api.dart' as api;

abstract class Media extends Equatable {
  final Uri address;
  final String vaultId;
  final String sha256;
  final String md5;
  final String mimeType;
  final String? filename;
  final int size;
  final Uint8List? content;
  final Uint8List? thumbnail;

  const Media({
    required this.address,
    required this.vaultId,
    required this.sha256,
    required this.md5,
    required this.mimeType,
    this.filename,
    required this.size,
    this.content,
    this.thumbnail,
  });

  factory Media.fromAPIModel({required api.Media model, required Uri address, required String vaultId}) {
    if (model is api.Image) {
      return Image.fromAPIModel(model: model, address: address, vaultId: vaultId);
    } else {
      throw UnimplementedError();
    }
  }

  Media copyWith({ValueGetter<Uint8List?>? content, ValueGetter<Uint8List?>? thumbnail});

  @override
  List<Object?> get props => [address, vaultId, sha256, md5, mimeType, filename, size, content == null, thumbnail == null];
}
