import 'package:flutter/material.dart' as material show Image;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_repository/media_repository.dart';
import 'package:stashed/app/constants.dart';
import 'package:stashed/viewer/cubits/viewer_cubit.dart';

class ViewerPage extends StatelessWidget {
  final List<Media> medias;
  final Media initialSelection;

  const ViewerPage({required this.medias, required this.initialSelection, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewerCubit(
        mediaRepository: context.read<MediaRepository>(),
        medias: medias,
        initialSelection: initialSelection,
      ),
      child: const _ViewerView(),
    );
  }
}

class _ViewerView extends StatelessWidget {
  const _ViewerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewerCubit, ViewerState>(
      builder: (context, state) {
        final cubit = context.read<ViewerCubit>();

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
            const SizedBox(height: spacingHeight),
            Expanded(
              child: FutureBuilder(
                future: cubit.loadContent(state.selectedMedia),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 2,
                      child: material.Image.memory(snapshot.data!.content!),
                    );
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
            const SizedBox(height: spacingHeight),
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: state.medias
                    .map(
                      (media) => SizedBox(
                        width: 64 + spacingHeight,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              cubit.selectMedia(media);
                            },
                            child: material.Image.memory(media.thumbnail!),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: spacingHeight),
          ],
        );
      },
    );
  }
}
