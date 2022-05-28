import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../resources/resources.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({Key? key, this.onTap}) : super(key: key);

  final Function? onTap;

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
          setState(() {});
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
              child: const Icon(
                Icons.download,
                size: 20,
                color: Colors.white,
              ),
            ),
    );
  }
}
