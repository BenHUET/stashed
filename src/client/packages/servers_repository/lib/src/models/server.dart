import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/stashed_api.dart';

part '../_generated/models/server.g.dart';

@JsonSerializable()
class Server extends Equatable {
  final String id;
  final String label;
  final Uri address;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final Manifest? manifest;

  const Server({
    required this.id,
    required this.label,
    required this.address,
    this.manifest,
  });

  Server copyWith({
    String? id,
    String? label,
    Uri? address,
    ValueGetter<Manifest?>? manifest,
  }) {
    return Server(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      manifest: manifest != null ? manifest() : this.manifest,
    );
  }

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
  Map<String, dynamic> toJson() => _$ServerToJson(this);

  @override
  List<Object?> get props => [id, label, address];
}
