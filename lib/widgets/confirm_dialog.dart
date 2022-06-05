import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../resources/locale/locale_keys.dart';

Future showConfirmDialog(BuildContext context, {Function? onYes, Function? onNo}) async {
  await showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text(LocaleKeys.changeDetection).tr(),
        content: const Text(LocaleKeys.doYouWantToSaveChanged).tr(),
        actions: [
          // The "Yes" button
          CupertinoDialogAction(
            onPressed: () async {
              await onYes?.call();
            },
            child: const Text(LocaleKeys.yes).tr(),
            isDefaultAction: true,
            isDestructiveAction: true,
          ),
          // The "No" button
          CupertinoDialogAction(
            onPressed: () async {
              await onNo?.call();
            },
            child: const Text(LocaleKeys.no).tr(),
            isDefaultAction: false,
            isDestructiveAction: false,
          )
        ],
      );
    },
  );
}
