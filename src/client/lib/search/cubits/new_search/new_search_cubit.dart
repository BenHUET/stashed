import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

part 'new_search_state.dart';

class NewSearchCubit extends Cubit<NewSearchState> {
  final VaultsRepository _vaultsRepository;
  final QueriesRepository _queriesRepository;

  NewSearchCubit({required VaultsRepository vaultsRepository, required QueriesRepository queriesRepository})
      : _vaultsRepository = vaultsRepository,
        _queriesRepository = queriesRepository,
        super(const NewSearchState()) {
    _vaultsRepository.getSelectedVaults().listen(
      (vaults) {
        emit(state.copyWith(selectedVaults: vaults));
      },
    );
  }

  Future<void> search() async {
    _queriesRepository.addQuery(
      SearchQuery.create(
        vaults: _vaultsRepository.selectedVaults.map((v) => (v.address, v.id)).toList(),
      ),
    );
  }
}
