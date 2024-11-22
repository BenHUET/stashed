import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/converters/media.dart';
import 'package:stashed_api/stashed_api.dart';

class ServerTaskJsonConverter extends JsonConverter<ServerTask, Map<String, dynamic>> {
  const ServerTaskJsonConverter();

  @override
  ServerTask fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'MediaImportTrackedTask' => _buildTask<Media>(
          json['trackedTaskDto'],
          ServerTaskType.mediaImport,
          json['result'] != null ? const MediaJsonConverter().fromJson(json['result']) : null,
        ),
      'GenerateThumbnailTrackedTask' => _buildTask<Thumbnail>(
          json['trackedTaskDto'],
          ServerTaskType.generateThumbnail,
          json['result'] != null ? Thumbnail.fromJson(json['result']) : null,
        ),
      _ => throw UnimplementedError()
    };
  }

  ServerTask<TResult> _buildTask<TResult>(Map<String, dynamic> json, ServerTaskType type, TResult? result) {
    return ServerTask<TResult>(
        type: type,
        id: json['id'] as String,
        vaultId: json['vaultId'] as String?,
        error: json['error'] as String?,
        dependsOnId: json['dependsOnId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        startedAt: json['startedAt'] == null ? null : DateTime.parse(json['startedAt'] as String),
        finishedAt: json['finishedAt'] == null ? null : DateTime.parse(json['finishedAt'] as String),
        status: json['status'] as int,
        result: result);
  }

  @override
  Map<String, dynamic> toJson(ServerTask object) {
    throw UnimplementedError();
  }
}
