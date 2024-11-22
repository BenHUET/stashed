import 'package:flutter/material.dart' as material show Image;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_repository/media_repository.dart';
import 'package:queries_repository/queries_repository.dart';
import 'package:stashed/app/constants.dart';
import 'package:stashed/search/cubits/search_result/search_result_cubit.dart';
import 'package:stashed/viewer/viewer.dart';

class SearchResultView extends StatefulWidget {
  final SearchQuery query;

  const SearchResultView({required this.query, super.key});

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => SearchResultCubit(
        queriesRepository: context.read<QueriesRepository>(),
        mediaRepository: context.read<MediaRepository>(),
        searchQuery: widget.query,
      ),
      child: const _SearchResultView(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SearchResultView extends StatelessWidget {
  const _SearchResultView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultCubit, SearchResultState>(
      builder: (context, state) {
        final cubit = context.read<SearchResultCubit>();
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Slider(
                  label: state.thumbnailSize.toString(),
                  value: state.sliderStep,
                  min: 6,
                  max: 8,
                  divisions: 2,
                  onChanged: (value) {
                    cubit.onThumbnailSizeChange(value);
                  },
                )
              ],
            ),
            const SizedBox(height: spacingHeight),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: state.thumbnailSize.toDouble(),
                  childAspectRatio: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                children: state.results
                    .map(
                      (media) => Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        width: state.thumbnailSize.toDouble(),
                        height: state.thumbnailSize.toDouble(),
                        child: InkWell(
                          onDoubleTap: () {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).push(
                              MaterialPageRoute(
                                builder: (_) => Theme(
                                  data: Theme.of(context),
                                  child: Scaffold(body: ViewerPage(medias: state.results, initialSelection: media)),
                                ),
                              ),
                            );
                          },
                          child: FutureBuilder(
                            future: cubit.loadThumbnail(media),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return material.Image.memory(snapshot.data!.thumbnail!);
                              } else if (snapshot.hasError) {
                                return const Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.no_photography_outlined),
                                    SizedBox(height: spacingHeight),
                                    Text("missing thumbnail"),
                                  ],
                                );
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
