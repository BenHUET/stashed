import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:stashed/search/search.dart';
import 'package:vaults_repository/vaults_repository.dart';

class NewSearchView extends StatelessWidget {
  const NewSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewSearchCubit(vaultsRepository: context.read<VaultsRepository>(), queriesRepository: context.read<QueriesRepository>()),
      child: const _NewSearchView(),
    );
  }
}

class _NewSearchView extends StatelessWidget {
  const _NewSearchView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<NewSearchCubit, NewSearchState>(
      builder: (context, state) {
        var cubit = context.read<NewSearchCubit>();
        return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchFieldHint,
                  ),
                ),
              ),
              TextIconButton(
                icon: Icons.search_outlined,
                text: l10n.searchSearch(state.selectedVaults.length),
                onPressed: state.selectedVaults.isNotEmpty
                    ? () {
                        cubit.search();
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
