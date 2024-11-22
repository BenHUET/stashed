// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../dtos/token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponseDTO _$TokenResponseDTOFromJson(Map<String, dynamic> json) =>
    TokenResponseDTO(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      refreshExpiresIn: json['refresh_expires_in'] as int,
      refreshToken: json['refresh_token'] as String,
    );
