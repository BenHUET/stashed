// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/file_vault.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileVault _$FileVaultFromJson(Map<String, dynamic> json) => FileVault(
      id: json['id'] as String,
      label: json['label'] as String,
      storage: _$JsonConverterFromJson<Map<String, dynamic>, Storage>(
          json['storage'], const StorageJsonConverter().fromJson),
      databaseDirectory: json['databaseDirectory'] as String?,
    );

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
