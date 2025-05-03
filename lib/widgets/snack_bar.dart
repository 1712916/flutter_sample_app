import 'package:flutter/material.dart';

abstract class SnackBarUtils {
  static bool isShowing = false;

  static void show(BuildContext context, String message) {
    if (isShowing) {
      return;
    }

    isShowing = true;

    final rs = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );

    rs.closed.then((_) {
      isShowing = false;
    });
  }
}
