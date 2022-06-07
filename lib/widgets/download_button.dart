import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../resources/resources.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({Key? key, this.onTap, this.icon = Icons.download}) : super(key: key);

  final Function? onTap;
  final IconData? icon;

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (!_isDownloading) {
          _isDownloading = true;
          setState(() {});
          await widget.onTap?.call();
          _isDownloading = false;
          if (mounted) {
            //todo: please [maybe have a bug here]
            setState(() {});
          }
        }
      },
      tooltip: LocaleKeys.downLoadThisImage.tr(),
      icon: _isDownloading
          ? const CircularProgressIndicator(
              color: Colors.grey,
              strokeWidth: 2,
            )
          : Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                widget.icon,
                size: 20,
                color: Colors.white,
              ),
            ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final Function? onTap;

  const CircleButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: const Icon(
          Icons.share,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
