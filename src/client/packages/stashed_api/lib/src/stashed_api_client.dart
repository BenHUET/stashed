import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:rfc_6902/rfc_6902.dart';
import 'package:stashed_api/src/converters/media.dart';
import 'package:stashed_api/src/converters/vault.dart';
import 'package:stashed_api/src/dtos/queued_work_result.dart';
import 'package:stashed_api/src/dtos/search_request.dart';
import 'package:stashed_api/src/dtos/search_response.dart';
import 'package:stashed_api/stashed_api.dart';

class StashedApiClient {
  final Dio _dio;

  StashedApiClient({required Dio dio}) : _dio = dio;

  Future<void> createAccount(Uri address, String email, String username) async {
    String uri = Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/user/register').toString();
    await _dio.post(
      uri,
      data: jsonEncode(
        {
          'email': email,
          'username': username,
        },
      ),
    );
  }

  Future<Manifest> getManifest(Uri address) async {
    final response = await _dio.get(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/server/manifest').toString(),
    );

    final manifest = Manifest.fromJson(response.data);

    return manifest;
  }

  Future<List<Vault>> getVaults(Uri address) async {
    final response = await _dio.get(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/server/vaults').toString(),
    );

    final vaults = (response.data as List).map((item) => const VaultJsonConverter().fromJson(item)).toList();

    return vaults;
  }

  Future<void> createVault(Uri address, CreateVaultRequestBuilder builder) async {
    String uri = Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/vault').toString();
    await _dio.post(uri, data: jsonEncode(builder.request));
  }

  Future<void> editVault(Uri address, String vaultId, String label) async {
    String uri = Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/vault/$vaultId').toString();

    await _dio.patch(
      uri,
      data: jsonEncode(
        JsonPatch.build(
          [Replace('/label', label)],
        ),
      ),
    );
  }

  Future<void> deleteVault(Uri address, String vaultId) async {
    await _dio.delete(Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/vault/$vaultId').toString());
  }

  Future<Set<String>> importMedia(Uri address, String vaultId, String path) async {
    var response = await _dio.post(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/media/$vaultId').toString(),
      data: FormData.fromMap(
        {
          'file': await MultipartFile.fromFile(path),
        },
      ),
    );
    var dto = QueuedWorkResultDto.fromJson(response.data);
    return dto.tasksIds;
  }

  Future<List<Media>> search(Uri address, String vaultId) async {
    var response = await _dio.post(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/media/search/$vaultId').toString(),
      data: const SearchRequestDTO(),
    );
    var dto = SearchResponseDTO.fromJson(response.data);
    return dto.medias;
  }

  Future<Thumbnail> getThumbnail(Uri address, String vaultId, String mediaId, int size) async {
    var response = await _dio.get(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/media/$vaultId/$mediaId/$size').toString(),
    );
    return Thumbnail.fromJson(response.data);
  }

  Future<Media> getMedia(Uri address, String vaultId, String mediaId) async {
    var response = await _dio.get(
      Uri(scheme: address.scheme, host: address.host, port: address.port, path: '/media/$vaultId/$mediaId').toString(),
    );
    return const MediaJsonConverter().fromJson(response.data);
  }
}
