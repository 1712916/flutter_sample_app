import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../resources/resources.dart';
import '../../widgets/widgets.dart';
import 'index.dart';

class DownloadHelper {
  DownloadHelper._();

  static Future<String> storagePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/meow_app';
  }

  static Future downloadImage({required String url}) async {
    Permission permission = Permission.photos;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        /// use [Permissions.storage.status]
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
      if (imageType == null) {
        return null;
      }

      final fileName = 'meow_app_${DateTime.now().millisecondsSinceEpoch}.$imageType';
      final path = '${await storagePath()}/$fileName';
      print('path: $path');

      final dio = Dio();
      await dio.download(url, path);
      await CRFileSaver.saveFile(path, destinationFileName: fileName);

      Toast.makeText(message: LKey.saveToPhone.tr());
    } catch (error) {
      log("download error", error: error);
    }
  }

  static Future<String?> downloadToInternal(String url) async {
    if (url.endsWith('.gif')) {
      return null;
    }

    String? imageType = url.split('.').lastOrNull;
    if (imageType == null) {
      return null;
    }
    final dio = Dio();
    String? path;
    try {
      final temp = await getTemporaryDirectory();
      path = '${temp.path}/game.${imageType}';
      await dio.download(url, path);
    } catch (e) {
      path = null;
      print('Download image: lỗi tải ảnh');
    }

    dio.close();
    return path;
  }

  static Future<XFile?> downloadToInternal2(String url) async {
    if (url.endsWith('.gif')) {
      return null;
    }

    String? imageType = url.split('.').lastOrNull;
    if (imageType == null) {
      return null;
    }
    final dio = Dio();
    String? path;
    try {
      final temp = await getTemporaryDirectory();
      path = '${temp.path}/game.${imageType}';
      await dio.download(url, path);
      dio.close();

      return XFile(path);
    } catch (e) {
      print('Download image: lỗi tải ảnh');
    }

    return null;
  }
}
