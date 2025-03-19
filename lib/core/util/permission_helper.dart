import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future request(Permission permission, {Function? onGranted, Function? onDenied}) async {
    PermissionStatus status = await permission.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      //open request permission dialog
      PermissionStatus requestStatus = await permission.request();
      if (requestStatus.isGranted) {
        await onGranted?.call();
      } else if (requestStatus.isDenied) {
        await onDenied?.call();
      } else if (requestStatus == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
    } else if (status.isGranted) {
      await onGranted?.call();
    }
  }
}