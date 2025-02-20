import '../../data/data.dart';
import '../cubits.dart';

enum ImageViewType {
  grid('/'),
  page('/page');

  const ImageViewType(this.path);
  final String path;

  static ImageViewType fromPath(String path) {
    return values.firstWhere((element) => element.path == path);
  }
}

class ImageListState extends BaseState {
  final List<SearchModel>? images;
  final ImageViewType viewType;

  ImageListState({
    this.images,
    required this.viewType,
    super.loadStatus,
  });

  factory ImageListState.init() {
    return ImageListState(
      images: [],
      viewType: ImageViewType.page,
      loadStatus: LoadStatus.init,
    );
  }

  @override
  List<Object?> get props => [
        images.hashCode,
        viewType,
        loadStatus,
      ];

  ImageListState copyWith({
    List<SearchModel>? images,
    ImageViewType? viewType,
    LoadStatus? loadStatus,
  }) {
    return ImageListState(
      images: images ?? this.images,
      viewType: viewType ?? this.viewType,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
