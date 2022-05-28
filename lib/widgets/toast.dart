import 'package:flutter/material.dart';

import '../main.dart';

class Toast {
  Toast._();

  static const int LENGTH_LONG = LENGTH_SHORT * 2;

  static const int LENGTH_SHORT = 800;

  // static Map<String, OverlayEntry> _temp = {};
  // static const String _tempKey = 'TEMP_KEY';

  static makeText({BuildContext? context, required String message,int toastLength = LENGTH_SHORT}) {
    OverlayState? overlayState = context != null ? Overlay.of(context) : navKey.currentState?.overlay;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (_) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(message),
              ),
            ),
          ],
        );
      },
    );
    overlayState?.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: toastLength)).then((_) {
      overlayEntry.remove();
    });
  }
}
