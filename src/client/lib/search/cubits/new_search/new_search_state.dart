part of 'new_search_cubit.dart';

class NewSearchState extends Equatable {
  final List<Vault> selectedVaults;

  const NewSearchState({
    this.selectedVaults = const [],
  });

  NewSearchState copyWith({
    List<Vault>? selectedVaults,
  }) {
    return NewSearchState(
      selectedVaults: selectedVaults ?? this.selectedVaults,
    );
  }

  @override
  List<Object?> get props => [selectedVaults];
}
