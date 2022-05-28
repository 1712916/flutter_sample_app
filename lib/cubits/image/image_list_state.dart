import '../../data/data.dart';
import '../cubits.dart';

class ImageListState extends BaseState implements Copyable<ImageListState> {
  final List<SearchModel>? images;

  ImageListState({this.images});

  @override
  ImageListState copy() {
    return this;
  }

  @override
  ImageListState copyWith({List<SearchModel>? images}) {
    return ImageListState(
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
        images.hashCode,
      ];
}
