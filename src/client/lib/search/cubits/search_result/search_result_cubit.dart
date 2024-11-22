import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:media_repository/media_repository.dart';
import 'package:queries_repository/queries_repository.dart';

part 'search_result_state.dart';

class SearchResultCubit extends Cubit<SearchResultState> {
  final MediaRepository _mediaRepository;
  StreamSubscription<SearchQuery>? _subscription;

  SearchResultCubit({required MediaRepository mediaRepository, required QueriesRepository queriesRepository, required SearchQuery searchQuery})
      : _mediaRepository = mediaRepository,
        super(SearchResultState(query: searchQuery, thumbnailSize: 64)) {
    _run();
  }

  void _run() async {
    final List<Media> media = [];
    for (var vault in state.query.vaults) {
      media.addAll(await _mediaRepository.search(vault.$1, vault.$2));
      emit(state.copyWith(results: media));
    }

    emit(state.copyWith(status: SearchResultStatus.success));
  }

  Future<Media> loadThumbnail(Media media) async {
    final result = await _mediaRepository.loadThumbnail(media, state.thumbnailSize);

    final index = state.results.indexWhere((element) => element.sha256 == media.sha256);
    final results = state.results;
    results[index] = result;

    emit(state.copyWith(results: results));

    return result;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  void onThumbnailSizeChange(double step) {
    emit(state.copyWith(thumbnailSize: pow(2, step).toInt()));
  }
}
