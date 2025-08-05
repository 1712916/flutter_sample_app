import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/widgets.dart';
import 'index.dart';

class DownloadHelper {
  DownloadHelper._();

  static Future<String> storagePath() async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/meow_app';

    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  static Future downloadImage({required String url}) async {
    Permission permission = Permission.photos;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permission = Permission.storage;
      }
    }

    await PermissionHelper.request(permission, onGranted: () async {
      return await InternetCheckerHelper.checkInternetAccess(
        onConnected: () async => await _downLoadImage(url),
        onDisconnected: () {
          Toast.makeText(message: LKey.checkInternetAccess.tr());
        },
      );
    });
  }

  static _downLoadImage(String url) async {
    try {
      String? imageType = url.split('.').lastOrNull;
      if (imageType == null) return null;

      final fileName = 'meow_app_${DateTime.now().millisecondsSinceEpoch}.$imageType';
      final path = '${await storagePath()}/$fileName';
      log('Download path: $path', name: 'DownloadHelper');

      final dio = Dio();
      await dio.download(url, path);
      await CRFileSaver.saveFile(path, destinationFileName: fileName);

      Toast.makeText(message: LKey.saveToPhone.tr());
    } catch (error) {
      log("Download error", error: error);
    }
  }

  static Future<String?> downloadToInternal(String url) async {
    if (url.endsWith('.gif')) return null;

    String? imageType = url.split('.').lastOrNull;
    if (imageType == null) return null;

    final dio = Dio();
    String? path;
    try {
      final temp = await getTemporaryDirectory();
      path = '${temp.path}/game.$imageType';
      await dio.download(url, path);
    } catch (e) {
      path = null;
      log('Download image: lỗi tải ảnh', error: e);
    }

    dio.close();
    return path;
  }

  static Future<XFile?> downloadToInternal2(String url) async {
    if (url.endsWith('.gif')) return null;

    String? imageType = url.split('.').lastOrNull;
    if (imageType == null) return null;

    final dio = Dio();
    String? path;
    try {
      final temp = await getTemporaryDirectory();
      path = '${temp.path}/game.$imageType';
      await dio.download(url, path);
      dio.close();

      return XFile(path);
    } catch (e) {
      log('Download image: lỗi tải ảnh', error: e);
    }

    return null;
  }

  static Future<void> downloadFromBitmap(Uint8List bitmap) async {
    final fileName = 'meow_app_${DateTime.now().millisecondsSinceEpoch}.png';
    final path = '${await storagePath()}/$fileName';

    try {
      final file = File(path);
      await file.writeAsBytes(bitmap);
      await CRFileSaver.saveFile(path, destinationFileName: fileName);
      Toast.makeText(message: LKey.saveToPhone.tr());
    } catch (e) {
      log("Download bitmap error", error: e);
    }
  }
}

class DownloadFromGithubUtil {
  static String gitHubRawUrl = 'https://raw.githubusercontent.com/bossxomlut/assets/main/';
  static String gitHubApiUrl = 'https://api.github.com/repos/bossxomlut/assets/contents/';

  static DownloadFromGithubUtil pikachuMeow = DownloadFromGithubUtil(
    downloadedKey: 'pikachuCatDownloaded',
    localFolderName: 'pikachu/cat',
    remoteFolderName: 'image/512/cat',
  );

  //pikachu gaow
  static DownloadFromGithubUtil pikachuGaow = DownloadFromGithubUtil(
    downloadedKey: 'pikachuDogDownloaded',
    localFolderName: 'pikachu/dog',
    remoteFolderName: 'image/512/dog',
  );

  DownloadFromGithubUtil({
    required this.downloadedKey,
    required this.localFolderName,
    required this.remoteFolderName,
  });

  final String downloadedKey;
  final String localFolderName;
  final String remoteFolderName;

  final Dio _dio = Dio();

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getBool(downloadedKey) ?? false;

      if (!downloaded) {
        final remoteFiles = await getRemoteFiles();

        log('Remote files: $remoteFiles', name: 'GithubDownload');

        if (remoteFiles.isEmpty) {
          log('No remote files found in $remoteFolderName', name: 'GithubDownload');
          return;
        }

        final dir = await getDirectory(localFolderName);

        const chunkSize = 10;
        for (var i = 0; i < remoteFiles.length; i += chunkSize) {
          final end = (i + chunkSize < remoteFiles.length) ? i + chunkSize : remoteFiles.length;
          final chunk = remoteFiles.sublist(i, end);

          await compute((message) async {
            final chunk = message['chunk'] as List<String>;
            final localFolderName = message['localFolderName'] as String;
            final rawFolderUrl = message['rawFolderUrl'] as String;
            final filePath = message['filePath'] as String;
            final downloadTasks = chunk.map((file) {
              final fileUrl = '$rawFolderUrl/$file';
              log('Downloading $file from $fileUrl', name: 'GithubDownload');
              return download(
                filename: file,
                url: fileUrl,
                localFolderName: localFolderName,
                filePath: '$filePath/$file',
              );
            }).toList();

            await Future.wait(downloadTasks);
          }, {
            'chunk': chunk,
            'localFolderName': localFolderName,
            'rawFolderUrl': rawFolderUrl,
            'filePath': '${dir.path}'
          });
        }

        await prefs.setBool(downloadedKey, true);
      }
    } catch (e) {
      log('Error initializing music manager', error: e);
    }
  }

  Future<List<String>> getRemoteFiles() async {
    try {
      final response = await _dio.get(apiFolderUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => item['name'] as String).toList();
      } else {
        log('Failed to fetch remote files: ${response.statusCode}', name: 'GithubDownload');
        return [];
      }
    } catch (e) {
      log('Error fetching remote files', error: e);
      return [];
    }
  }

  String get rawFolderUrl => '$gitHubRawUrl$remoteFolderName';

  String get apiFolderUrl => '$gitHubApiUrl$remoteFolderName';

  Future<List<String>> getAvailableFiles() async {
    try {
      final dir = await getDirectory(localFolderName);
      final files = dir.listSync().whereType<File>().map((file) => file.path.split('/').last).toList();
      return files;
    } catch (e) {
      log('Error listing files', error: e);
      return [];
    }
  }

  Future<List<String>> getAvailableFilePaths() async {
    try {
      final dir = await getDirectory(localFolderName);
      final files = dir.listSync().whereType<File>().map((file) => file.path).toList();
      return files;
    } catch (e) {
      log('Error listing file paths', error: e);
      return [];
    }
  }
}

Future<Directory> getDirectory(String folder) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileDirectory = Directory('${appDir.path}/$folder');

  if (!await fileDirectory.exists()) {
    await fileDirectory.create(recursive: true);
  }

  return fileDirectory;
}

Future<void> download({
  required String filename,
  required String filePath,
  required String url,
  required String localFolderName,
}) async {
  try {
    final _dio = Dio();

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          log('Download $filename: ${(received / total * 100).toStringAsFixed(0)}%', name: 'DownloadProgress');
        }
      },
    );

    log('Downloaded $filename to $filePath', name: 'DownloadComplete');
  } catch (e, st) {
    log('Error downloading $filename', error: e, stackTrace: st);
  }
}
