import 'package:flutter/material.dart';
import 'package:queries_repository/queries_repository.dart';

class SearchQuery extends Query {
  final List<(Uri, String)> vaults;

  const SearchQuery({required this.vaults, required super.id});

  SearchQuery.create({required List<(Uri, String)> vaults}) : this(id: UniqueKey().toString(), vaults: vaults);

  @override
  List<Object?> get props => [id, vaults];
}
