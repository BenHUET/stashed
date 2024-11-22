import 'package:json_annotation/json_annotation.dart';
import 'package:stashed_api/src/converters/media.dart';
import 'package:stashed_api/stashed_api.dart';

part '../_generated/dtos/search_response.g.dart';

@JsonSerializable(createToJson: false)
class SearchResponseDTO {
  @MediaJsonConverter()
  final List<Media> medias;

  const SearchResponseDTO({required this.medias});

  factory SearchResponseDTO.fromJson(Map<String, dynamic> json) => _$SearchResponseDTOFromJson(json);
}
