import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:stashed/app/constants.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:stashed/search/search.dart';
import 'package:stashed/search/views/new_search.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(queriesRepository: context.read<QueriesRepository>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocConsumer<SearchCubit, SearchState>(
      listenWhen: (previous, current) {
        return (current.selectedQuery != null && previous.selectedQuery != current.selectedQuery);
      },
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            final cubit = context.read<SearchCubit>();

            cubit.selectQuery(state.selectedQuery!);
            cubit.pageController.jumpToPage(state.queries.indexOf(state.selectedQuery!));
          },
        );
      },
      builder: (context, state) {
        final cubit = context.read<SearchCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: VaultsPicker(),
            ),
            const NewSearchView(),
            const SizedBox(height: spacingHeight),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: state.queries.reversed.map(
                        (q) {
                          bool isSelected = state.selectedQuery?.id == q.id;
                          return SizedBox(
                            height: 50,
                            child: Card(
                              key: Key(q.id),
                              color: isSelected ? theme.colorScheme.secondaryContainer : theme.colorScheme.background,
                              child: InkWell(
                                child: Center(
                                  child: Text(q.id),
                                ),
                                onTap: () {
                                  cubit.selectQuery(q);
                                },
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(width: spacingWidth),
                  Expanded(
                    child: PageView(
                      controller: cubit.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: state.queries.map((q) {
                        return SearchResultView(query: q);
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
