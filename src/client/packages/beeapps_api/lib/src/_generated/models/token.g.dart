// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      jwt: json['jwt'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'jwt': instance.jwt,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
