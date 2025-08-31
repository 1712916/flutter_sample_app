import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../data/models/image_storage_model.dart';
import '../../data/repositories/image_storage_repository.dart';
import 'app_image_storage.dart';

/// Wrapper utility to manage images using both file storage and the image storage repository.
class AppImageManager {
  final ImageStorageRepository _repo;

  AppImageManager(this.feature, {ImageStorageRepository? repository})
      : _repo = repository ?? ImageStorageRepository.instance;

  final ImageStorageFeature? feature;

  //save from path
  /// Save image from file path and register in repository. Returns the model.

  Future<ImageStorageModel> saveImageFromPath(
    String filePath, {
    String? fileName,
    String? url,
  }) async {
    final bytes = await AppImageStorage.loadImage(filePath);
    return saveImage(bytes, fileName: fileName, url: url);
  }

  /// Save image bytes to file and register in repository. Returns the model.
  Future<ImageStorageModel> saveImage(Uint8List bytes, {String? fileName, String? url}) async {
    final path = await AppImageStorage.saveImage(bytes, fileName: fileName);
    final model = ImageStorageModel(
      id: 0, // Let repository handle auto-increment
      path: path,
      feature: feature,
    );
    final saved = await _repo.create(model);
    return saved;
  }

  /// Load image bytes from file by model or path.
  Future<Uint8List> loadImage(ImageStorageModel model) async {
    if (model.path == null) throw Exception('No file path in model');
    return AppImageStorage.loadImage(model.path!);
  }

  /// Delete image file and remove from repository.
  Future<void> deleteImage(ImageStorageModel model) async {
    if (model.path != null) {
      await AppImageStorage.deleteImage(model.path!);
    }
    await _repo.delete(model);
  }

  /// List all images (from repository).
  Future<List<ImageStorageModel>> listImages() async {
    return _repo.getAll();
  }

  /// Clear all images (files and repository entries).
  Future<void> clearAll() async {
    final images = await _repo.getAll();
    for (final img in images) {
      if (img.path != null) {
        await AppImageStorage.deleteImage(img.path!);
      }
      await _repo.delete(img);
    }
  }
}
