part of 'search_result_cubit.dart';

enum SearchResultStatus { initial, loading, success, failure }

class SearchResultState extends Equatable {
  final SearchQuery query;
  final SearchResultStatus status;
  final List<Media> results;
  final int thumbnailSize;
  double get sliderStep => log(thumbnailSize) / log(2);

  const SearchResultState({
    required this.query,
    required this.thumbnailSize,
    this.status = SearchResultStatus.initial,
    this.results = const [],
  });

  SearchResultState copyWith({
    SearchResultStatus? status,
    SearchQuery? query,
    List<Media>? results,
    int? thumbnailSize,
  }) {
    return SearchResultState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }

  @override
  List<Object?> get props => [query, status, results, thumbnailSize];
}
