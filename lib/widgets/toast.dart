import 'package:flutter/material.dart';

import '../main.dart';

class Toast {
  Toast._();

  static const int LENGTH_LONG = LENGTH_SHORT * 2;

  static const int LENGTH_SHORT = 1000;

  // static Map<String, OverlayEntry> _temp = {};
  // static const String _tempKey = 'TEMP_KEY';

  static makeText({BuildContext? context, required String message, int toastLength = LENGTH_SHORT}) {
    OverlayState? overlayState = context != null ? Overlay.of(context) : navKey.currentState?.overlay;
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (_) {
        return _ToastContent(message: message);
      },
    );
    overlayState?.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: toastLength)).then((_) {
      overlayEntry.remove();
    });
  }
}

class _ToastContent extends StatefulWidget {
  const _ToastContent({super.key, required this.message});
  final String message;

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent> {
  bool startAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        startAnimation = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.cardColor;
    return Stack(
      alignment: Alignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: startAnimation ? bgColor.withOpacity(0.8) : bgColor.withOpacity(0.0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }
}
