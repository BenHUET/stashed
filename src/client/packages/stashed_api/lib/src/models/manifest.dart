import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '../_generated/models/manifest.g.dart';

@JsonSerializable(createToJson: false)
class Manifest extends Equatable {
  final String version;
  final bool authEnabled;

  const Manifest({
    required this.version,
    required this.authEnabled,
  });

  factory Manifest.fromJson(Map<String, dynamic> json) => _$ManifestFromJson(json);

  @override
  List<Object?> get props => [version, authEnabled];
}
