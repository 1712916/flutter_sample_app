import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Utility for storing and managing image files for internal app use.
class AppImageStorage {
  static Future<Directory> _getImageDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(dir.path, 'images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  /// Save image bytes to a file. Returns the file path.
  static Future<String> saveImage(Uint8List bytes, {String? fileName}) async {
    final dir = await _getImageDir();
    final name = fileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Load image bytes from a file path.
  static Future<Uint8List> loadImage(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('Image not found: $filePath');
    return await file.readAsBytes();
  }

  /// Delete an image file by path.
  static Future<void> deleteImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// List all image file paths in the storage directory.
  static Future<List<String>> listImages() async {
    final dir = await _getImageDir();
    final files = dir.listSync().whereType<File>();
    return files.map((f) => f.path).toList();
  }

  /// Clear all stored images.
  static Future<void> clearAll() async {
    final dir = await _getImageDir();
    final files = dir.listSync().whereType<File>();
    for (final file in files) {
      await file.delete();
    }
  }
}
