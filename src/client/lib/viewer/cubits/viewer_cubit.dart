import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:media_repository/media_repository.dart';

part 'viewer_state.dart';

class ViewerCubit extends Cubit<ViewerState> {
  final MediaRepository _mediaRepository;

  ViewerCubit({
    required MediaRepository mediaRepository,
    required List<Media> medias,
    required Media initialSelection,
  })  : _mediaRepository = mediaRepository,
        super(ViewerState(
          medias: medias,
          selectedIndex: medias.indexWhere((m) => m.sha256 == initialSelection.sha256),
        ));

  Future<Media> loadContent(Media media) async {
    var result = await _mediaRepository.loadContent(media);

    final index = state.medias.indexWhere((element) => element.sha256 == media.sha256);
    final medias = state.medias;
    medias[index] = result;

    emit(state.copyWith(medias: medias));

    return result;
  }

  void selectMedia(Media media) {
    emit(state.copyWith(selectedIndex: state.medias.indexWhere((m) => m.sha256 == media.sha256)));
  }
}
