import '../../data/data.dart';
import '../cubits.dart';

class ImageState extends BaseState implements Copyable<ImageState> {

  ImageState({LoadStatus? loadStatus}): super(loadStatus: loadStatus);
  @override
  ImageState copy() {
    return this;
  }

  @override
  ImageState copyWith() {
    return ImageState();
  }

  @override
  List<Object?> get props => [];

}