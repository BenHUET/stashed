import 'package:equatable/equatable.dart';

abstract class Query extends Equatable {
  final String id;

  const Query({required this.id});
}
