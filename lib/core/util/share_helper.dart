import 'dart:io';
import 'dart:ui' as ui;

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/widgets.dart';
import 'download_helper.dart';
import 'internet_checker_helper.dart';

class ShareHelper {
  static bool _lock = false;

  static Future shareImage({String? url}) async {
    await InternetCheckerHelper.checkInternetAccess(
      onConnected: () async => await _shareImage(url),
      onDisconnected: () {
        Toast.makeText(message: LKey.checkInternetAccess.tr());
      },
    );
  }

  static _shareImage(String? url) async {
    if (!_lock) {
      _lock = true;
      final dio = Dio();
      try {
        final file = await DownloadHelper.downloadToInternal2(url!);
        await Share.shareXFiles([file!], subject: LKey.shareFile.tr());
      } on PlatformException catch (error) {
        Toast.makeText(message: LKey.errorWhenTryShare.tr());
      } on DioError catch (error) {
        Toast.makeText(message: LKey.checkInternetAccess.tr());
      } catch (error) {
        Toast.makeText(message: LKey.errorWhenTryShare.tr());
      }
      dio.close();
      _lock = false;
    } else {
      Toast.makeText(message: LKey.waitToShare.tr());
    }
  }

  static Future shareToMessage({String? url}) async {
    try {
      final file = await DownloadHelper.downloadToInternal2(url!);
      if (Platform.isIOS) {
        await AppinioSocialShare().iOS.shareImageToWhatsApp(file!.path!);
      } else if (Platform.isAndroid) {
        await AppinioSocialShare().android.shareToSMS('Image from meow_app', file!.path);
      }
    } catch (error) {
      Toast.makeText(message: LKey.errorWhenTryShare.tr());
    }
  }

  static Future shareToInstagram({String? url}) async {
    try {
      final file = await DownloadHelper.downloadToInternal2(url!);
      if (Platform.isIOS) {
        await AppinioSocialShare().iOS.shareToInstagramFeed(file!.path!);
      } else if (Platform.isAndroid) {
        await AppinioSocialShare().android.shareToInstagramFeed('', file!.path);
      }
    } catch (error) {
      Toast.makeText(message: LKey.errorWhenTryShare.tr());
    }
  }

  static Future shareToTwitter({String? url}) async {
    try {
      final file = await DownloadHelper.downloadToInternal2(url!);
      if (Platform.isIOS) {
        await AppinioSocialShare().iOS.shareToTwitter('', file!.path!);
      } else if (Platform.isAndroid) {
        await AppinioSocialShare().android.shareToTwitter('', file!.path);
      }
    } catch (error) {
      Toast.makeText(message: LKey.errorWhenTryShare.tr());
    }
  }

  static Future shareBitmap(Uint8List bitmap) async {
    try {
      //get image size from bitmap
      final codec = await ui.instantiateImageCodec(bitmap);
      final frameInfo = await codec.getNextFrame();
      final w = frameInfo.image.width;
      final minWidth = 120;

      final inSampleSize = (w / minWidth).floor();
      final file = await FlutterImageCompress.compressWithList(
        bitmap,
        quality: 100,
        format: CompressFormat.png,
        minWidth: minWidth,
        inSampleSize: inSampleSize,
      );

      await Share.shareXFiles([
        XFile.fromData(file, mimeType: 'image/gif'),
      ], subject: LKey.shareFile.tr());
    } catch (error) {
      Toast.makeText(message: LKey.errorWhenTryShare.tr());
    }
  }
}
