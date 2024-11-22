import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:queries_repository/queries_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final QueriesRepository _queriesRepository;
  final PageController pageController;

  SearchCubit({required QueriesRepository queriesRepository})
      : _queriesRepository = queriesRepository,
        pageController = PageController(),
        super(const SearchState()) {
    _queriesRepository.getSearchQueries().listen(
      (queries) {
        emit(state.copyWith(status: SearchStatus.success, queries: queries, selectedQuery: state.selectedQuery));
        if (queries.isNotEmpty) {
          selectQuery(state.queries.last);
        }
      },
    );
  }

  void selectQuery(SearchQuery query) {
    emit(state.copyWith(selectedQuery: query));
  }
}
