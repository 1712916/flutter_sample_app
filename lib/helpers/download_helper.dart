import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/widgets.dart';
import 'helpers.dart';

class DownloadHelper {
  DownloadHelper._();

  static Future downloadImage({required String url}) async {
    await PermissionHelper.request(Permission.storage, onGranted: () {
      InternetCheckerHelper.checkInternetAccess(
        onConnected: () => _downLoadImage(url),
        onDisconnected: () {},
      );
    });
  }

  static _downLoadImage(String url) async {
    try {
      // Saved with this method.
      //chọn địa chỉ => Mình sẽ set up ở màn setting
      //sẽ lưu vào một cái folder nào đó
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }
      Toast.makeText(message: 'Ảnh đã được lưu vào thiết bị này');

    } on PlatformException catch (error) {
      print(error);
      Toast.makeText(message: 'Đã xảy ra lỗi');
    }
  }
}