import 'dart:convert';

import 'package:auth_repository/auth_repository.dart';
import 'package:beeapps_api/beeapps_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

class NotAuthenticatedException implements Exception {}

class AuthRepository {
  final BeeappsApiClient _beeappsApiClient;
  final FlutterSecureStorage _secureStorage;
  final Map<String, Token> _accessTokens = {};

  final _userStreamController = BehaviorSubject<User?>.seeded(null);

  AuthRepository({required BeeappsApiClient beeappsApiClient, required FlutterSecureStorage secureStorage})
      : _beeappsApiClient = beeappsApiClient,
        _secureStorage = secureStorage;

  Future<void> init() async {
    await _broadcastUserFromOfflineToken();
  }

  Stream<User?> getUser() => _userStreamController.asBroadcastStream();

  Future<void> login(String email, String password) async {
    final (accessToken, refreshToken) = await _beeappsApiClient.getTokensWithCredentials(email, password, "none");

    await _secureStorage.write(key: 'offlineRefreshToken', value: jsonEncode(refreshToken.toJson()));
    await _secureStorage.write(key: 'offlineAccessToken', value: jsonEncode(accessToken.toJson()));

    await _broadcastUserFromOfflineToken();
  }

  Future<void> logout() async {
    final offlineRefreshTokenJson = await _secureStorage.read(key: 'offlineRefreshToken');
    final offlineRefreshToken = Token.fromJson(jsonDecode(offlineRefreshTokenJson!));

    await _secureStorage.delete(key: 'offlineRefreshToken');
    await _secureStorage.delete(key: 'offlineAccessToken');
    _accessTokens.clear();

    _userStreamController.add(null);

    _beeappsApiClient.revokeToken(offlineRefreshToken.jwt);
  }

  Future<String> getAccessToken(String audience) async {
    try {
      if (_accessTokens.containsKey(audience)) {
        final token = _accessTokens[audience]!;
        if (!token.isExpired) {
          return token.jwt;
        }
      }

      final offlineTokenJson = await _secureStorage.read(key: 'offlineRefreshToken');
      final offlineToken = Token.fromJson(jsonDecode(offlineTokenJson!));

      final (accessToken, _) = await _beeappsApiClient.getTokenWithRefreshToken(offlineToken.jwt, audience);

      _accessTokens[audience] = accessToken;

      return accessToken.jwt;
    } catch (e) {
      _userStreamController.addError(e);
      rethrow;
    }
  }

  Future<void> _broadcastUserFromOfflineToken() async {
    User? user;

    final offlineRefreshTokenJson = await _secureStorage.read(key: 'offlineRefreshToken');
    final offlineAccessTokenJson = await _secureStorage.read(key: 'offlineAccessToken');

    if (offlineRefreshTokenJson != null && offlineAccessTokenJson != null) {
      final offlineRefreshToken = Token.fromJson(jsonDecode(offlineRefreshTokenJson));
      final offlineAccessToken = Token.fromJson(jsonDecode(offlineAccessTokenJson));

      final jwtRefreshToken = parseJwt(offlineRefreshToken.jwt);
      final jwtAccessToken = parseJwt(offlineAccessToken.jwt);

      user = User(id: jwtRefreshToken['sub'], username: jwtAccessToken['preferred_username']);
    }

    _userStreamController.add(user);
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');

    final normalizedSource = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalizedSource));
    final payloadMap = json.decode(payload);

    return payloadMap;
  }
}
