part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<SearchQuery> queries;
  final SearchQuery? selectedQuery;

  const SearchState({
    this.status = SearchStatus.initial,
    this.queries = const [],
    this.selectedQuery,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<SearchQuery>? queries,
    SearchQuery? selectedQuery,
  }) {
    return SearchState(
      status: status ?? this.status,
      queries: queries ?? this.queries,
      selectedQuery: selectedQuery,
    );
  }

  @override
  List<Object?> get props => [status, queries, selectedQuery];
}
