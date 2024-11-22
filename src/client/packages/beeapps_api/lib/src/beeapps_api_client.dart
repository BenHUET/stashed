import 'package:beeapps_api/src/dtos/token_response.dart';
import 'package:beeapps_api/src/models/token.dart';
import 'package:dio/dio.dart';

class BeeappsApiClient {
  final Dio _dio;

  BeeappsApiClient({required Dio dio}) : _dio = dio;

  Future<(Token, Token)> getTokensWithCredentials(String email, String password, String audience) async {
    var queryDate = DateTime.now();

    var response = await _dio.post(
      '/token',
      data: {
        'grant_type': 'password',
        'client_id': 'stashed',
        'scope': 'offline_access',
        'username': email,
        'password': password,
        'aud': audience,
      },
    );

    var dto = TokenResponseDTO.fromJson(response.data);
    return (
      Token.fromDto(jwt: dto.accessToken, expiresIn: dto.expiresIn, createdAt: queryDate),
      Token.fromDto(jwt: dto.refreshToken, expiresIn: dto.refreshExpiresIn, createdAt: queryDate)
    );
  }

  Future<void> revokeToken(String token) async {
    await _dio.post(
      '/revoke',
      data: {
        'client_id': 'stashed',
        'token': token,
      },
    );
  }

  Future<(Token, Token)> getTokenWithRefreshToken(String refreshToken, String audience) async {
    var queryDate = DateTime.now();

    var response = await _dio.post(
      '/token',
      data: {
        'grant_type': 'refresh_token',
        'client_id': 'stashed',
        'refresh_token': refreshToken,
        'aud': audience,
      },
    );

    var dto = TokenResponseDTO.fromJson(response.data);
    return (
      Token.fromDto(jwt: dto.accessToken, expiresIn: dto.expiresIn, createdAt: queryDate),
      Token.fromDto(jwt: dto.refreshToken, expiresIn: dto.refreshExpiresIn, createdAt: queryDate)
    );
  }
}
