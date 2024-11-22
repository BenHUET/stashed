import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '../_generated/models/token.g.dart';

@JsonSerializable()
class Token extends Equatable {
  final String jwt;
  final DateTime? expiresAt;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  const Token({
    required this.jwt,
    required this.expiresAt,
  });

  Token.fromDto({
    required this.jwt,
    required DateTime createdAt,
    required int? expiresIn,
  }) : expiresAt = expiresIn == null ? null : createdAt.add(Duration(seconds: expiresIn));

  Map<String, dynamic> toJson() => _$TokenToJson(this);
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  @override
  List<Object?> get props => [jwt, expiresAt];
}
