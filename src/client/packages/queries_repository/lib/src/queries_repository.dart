import 'dart:async';

import 'package:queries_repository/queries_repository.dart';
import 'package:rxdart/rxdart.dart';

class QueriesRepository {
  final _searchQueriesStreamController = BehaviorSubject<List<SearchQuery>>.seeded(const []);

  QueriesRepository();

  Stream<List<SearchQuery>> getSearchQueries() => _searchQueriesStreamController.asBroadcastStream();

  void addQuery(Query query) {
    if (query is SearchQuery) {
      _addSearchQuery(query);
    } else {
      throw UnimplementedError();
    }
  }

  void _addSearchQuery(SearchQuery query) {
    final queries = [..._searchQueriesStreamController.value];
    queries.add(query);
    _searchQueriesStreamController.add(queries);
  }

  void updateQuery(SearchQuery query) {
    final queries = [..._searchQueriesStreamController.value];

    var index = queries.indexWhere((q) => q.id == query.id);
    if (index == -1) {
      throw ArgumentError();
    }

    queries[index] = query;

    _searchQueriesStreamController.add(queries);
  }
}
