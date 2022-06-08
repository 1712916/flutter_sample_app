import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:meow_app/resources/locale/locale_keys.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/widgets.dart';
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
        final temp = await getTemporaryDirectory();
        final path = '${temp.path}/image.${url?.split('.').last}';
        await dio.download(url!, path);
        await Share.shareFiles([path], subject: LocaleKeys.shareFile.tr());
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
}
