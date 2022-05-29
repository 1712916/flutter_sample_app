import 'package:flutter/cupertino.dart';

Future showConfirmDialog(BuildContext context, {Function? onYes, Function? onNo}) async {
  await showCupertinoDialog(
      context: context,
      builder: (context) {
    return CupertinoAlertDialog(
      title: const Text('Phát hiện thay đổi'),
      content: const Text('Bạn có muốn lưu thay đổi không'),
      actions: [
        // The "Yes" button
        CupertinoDialogAction(
          onPressed: () async {
            await onYes?.call();
          },
          child: const Text('Yes'),
          isDefaultAction: true,
          isDestructiveAction: true,
        ),
        // The "No" button
        CupertinoDialogAction(
          onPressed: () async {
            await onNo?.call();
          },
          child: const Text('No'),
          isDefaultAction: false,
          isDestructiveAction: false,
        )
      ],
    );
  });
}