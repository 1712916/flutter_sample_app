import 'package:collection/collection.dart';
import 'package:dio/dio.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../resources/resources.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'helpers.dart';

class DownloadHelper {
  DownloadHelper._();

  static Future downloadImage({required String url}) async {
    await PermissionHelper.request(Permission.storage, onGranted: () async {
      await InternetCheckerHelper.checkInternetAccess(
        onConnected: () async => await _downLoadImage(url),
        onDisconnected: () {
          Toast.makeText(message: LocaleKeys.checkInternetAccess.tr());
        },
      );
    });
  }

  static _downLoadImage(String url) async {
    try {
      // Saved with this method.
      //chọn địa chỉ => Mình sẽ set up ở màn setting
      //sẽ lưu vào một cái folder nào đó
      var imageId = await ImageDownloader.downloadImage(url, destination: AndroidDestinationType.directoryPictures);
      /// todo lỗi khi chọn cái địa chỉ mình tự gán vào
      // var imageId = await ImageDownloader.downloadImage(url, destination: AndroidDestinationType.custom(directory: SettingManager.downloadPath.split('/').last));
      if (imageId == null) {
        return;
      }
      Toast.makeText(message: LocaleKeys.saveToPhone.tr());
    } on PlatformException catch (error) {
      Toast.makeText(message: LocaleKeys.haveAnError.tr());
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
}
