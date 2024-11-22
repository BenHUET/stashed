// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../dtos/search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseDTO _$SearchResponseDTOFromJson(Map<String, dynamic> json) =>
    SearchResponseDTO(
      medias: (json['medias'] as List<dynamic>)
          .map((e) =>
              const MediaJsonConverter().fromJson(e as Map<String, dynamic>))
          .toList(),
    );
