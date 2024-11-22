part of 'viewer_cubit.dart';

class ViewerState extends Equatable {
  final List<Media> medias;
  final int selectedIndex;
  Media get selectedMedia => medias[selectedIndex];

  const ViewerState({
    required this.medias,
    required this.selectedIndex,
  });

  ViewerState copyWith({
    List<Media>? medias,
    int? selectedIndex,
  }) {
    return ViewerState(
      medias: medias ?? this.medias,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object> get props => [medias, selectedIndex];
}
