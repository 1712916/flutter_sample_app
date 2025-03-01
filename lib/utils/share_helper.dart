import 'dart:io';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:meow_app/resources/locale/locale_keys.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/widgets.dart';
import 'download_helper.dart';
import 'internet_checker_helper.dart';

class ShareHelper {
  static bool _lock = false;

  static Future shareImage({String? url}) async {
    await InternetCheckerHelper.checkInternetAccess(
      onConnected: () async => await _shareImage(url),
      onDisconnected: () {
        Toast.makeText(message: LocaleKeys.checkInternetAccess.tr());
      },
    );
  }

  static _shareImage(String? url) async {
    if (!_lock) {
      _lock = true;
      final dio = Dio();
      try {
        final file = await DownloadHelper.downloadToInternal2(url!);
        await Share.shareXFiles([file!], subject: LocaleKeys.shareFile.tr());
      } on PlatformException catch (error) {
        Toast.makeText(message: LocaleKeys.errorWhenTryShare.tr());
      } on DioError catch (error) {
        Toast.makeText(message: LocaleKeys.checkInternetAccess.tr());
      } catch (error) {
        Toast.makeText(message: LocaleKeys.errorWhenTryShare.tr());
      }
      dio.close();
      _lock = false;
    } else {
      Toast.makeText(message: LocaleKeys.waitToShare.tr());
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
      Toast.makeText(message: LocaleKeys.errorWhenTryShare.tr());
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
      Toast.makeText(message: LocaleKeys.errorWhenTryShare.tr());
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
      Toast.makeText(message: LocaleKeys.errorWhenTryShare.tr());
    }
  }
}
