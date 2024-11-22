import 'package:cache_api/cache_api.dart';
import 'package:media_repository/media_repository.dart';
import 'package:stashed_api/stashed_api.dart' hide Media;

class MediaRepository {
  final StashedApiClient _stashedApiClient;
  final CacheApiClient _cacheApi;

  MediaRepository({
    required StashedApiClient stashedApiClient,
    required CacheApiClient cacheApi,
  })  : _cacheApi = cacheApi,
        _stashedApiClient = stashedApiClient;

  Future<Set<String>> importMedia(Uri address, String vaultId, String file) async {
    return await _stashedApiClient.importMedia(address, vaultId, file);
  }

  Future<List<Media>> search(Uri address, String vaultId) async {
    final results = await _stashedApiClient.search(address, vaultId);
    return results.map((m) => Media.fromAPIModel(model: m, address: address, vaultId: vaultId)).toList();
  }

  Future<Media> loadThumbnail(Media media, int size) async {
    // From cache or server
    var thumbnail = await _cacheApi.get("t_${media.sha256}_$size");

    if (thumbnail == null) {
      final result = await _stashedApiClient.getThumbnail(media.address, media.vaultId, media.sha256, size);
      thumbnail = result.content;
      _cacheApi.write("t_${media.sha256}_$size", thumbnail!);
    }

    return media.copyWith(thumbnail: () => thumbnail);
  }

  Future<Media> loadContent(Media media) async {
    // From cache or server
    var content = await _cacheApi.get(media.sha256);

    if (content == null) {
      final result = await _stashedApiClient.getMedia(media.address, media.vaultId, media.sha256);
      content = result.content;
      _cacheApi.write(media.sha256, content!);
    }

    return media.copyWith(content: () => content);
  }
}
