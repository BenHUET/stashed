import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '../_generated/dtos/token_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class TokenResponseDTO extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;

  const TokenResponseDTO({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.refreshToken,
  });

  factory TokenResponseDTO.fromJson(Map<String, dynamic> json) => _$TokenResponseDTOFromJson(json);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, refreshExpiresIn];
}
