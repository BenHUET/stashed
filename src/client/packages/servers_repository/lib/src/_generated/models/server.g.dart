// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Server _$ServerFromJson(Map<String, dynamic> json) => Server(
      id: json['id'] as String,
      label: json['label'] as String,
      address: Uri.parse(json['address'] as String),
    );

Map<String, dynamic> _$ServerToJson(Server instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'address': instance.address.toString(),
    };
