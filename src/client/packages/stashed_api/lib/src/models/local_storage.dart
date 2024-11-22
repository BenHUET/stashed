import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/stashed_api.dart';

part '../_generated/models/local_storage.g.dart';

@JsonSerializable(createToJson: false)
class LocalStorage extends Storage {
  final String? filesDirectory;

  const LocalStorage({
    required this.filesDirectory,
  });

  factory LocalStorage.fromJson(Map<String, dynamic> json) => _$LocalStorageFromJson(json);

  @override
  List<Object?> get props => [filesDirectory];
}
