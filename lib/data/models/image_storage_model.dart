import 'package:equatable/equatable.dart';

import '../repositories/isar_repository.dart';

enum ImageStorageFeature {
  none,
  sticker,
  chat;

  //factory from String
  factory ImageStorageFeature.fromString(String value) {
    switch (value) {
      case 'sticker':
        return ImageStorageFeature.sticker;
      case 'chat':
        return ImageStorageFeature.chat;
      default:
        return ImageStorageFeature.none;
    }
  }

  //to String
  @override
  String toString() {
    switch (this) {
      case ImageStorageFeature.sticker:
        return 'sticker';
      case ImageStorageFeature.chat:
        return 'chat';
      default:
        return 'none';
    }
  }
}

//create extension for ImageStorageFeature from String
extension ImageStorageFeatureExtension on String {
  ImageStorageFeature toImageStorageFeature() {
    return ImageStorageFeature.fromString(this);
  }
}

class ImageStorageModel extends Equatable implements GetId<int> {
  final int id;
  final String? url;
  final String? path;
  final List<int>? bytes;
  final ImageStorageFeature? feature;

  ImageStorageModel({
    required this.id,
    this.url,
    this.path,
    this.bytes,
    this.feature,
  });

  @override
  int? get getId => id;

  @override
  List<Object?> get props => [
        id,
        url,
        path,
        bytes,
        feature,
      ];
}
