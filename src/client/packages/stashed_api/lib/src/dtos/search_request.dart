import 'package:json_annotation/json_annotation.dart';

part '../_generated/dtos/search_request.g.dart';

@JsonSerializable(createFactory: false)
class SearchRequestDTO {
  const SearchRequestDTO();

  Map<String, dynamic> toJson() => _$SearchRequestDTOToJson(this);
}
