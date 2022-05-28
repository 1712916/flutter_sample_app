import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../cubits/cubits.dart';
import '../../../data/data.dart';
import '../../../helpers/helpers.dart';
import '../base_page/base_page.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key, this.cubit, this.searchModel}) : super(key: key);
  final ImageCubit? cubit;
  final SearchModel? searchModel;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends CustomState<ImagePage, ImageCubit> {
  SearchModel? searchModel;

  @override
  void initState() {
    if (widget.searchModel != null) {
      searchModel = widget.searchModel;
    }
    super.initState();
  }

  @override
  Widget buildContent(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PhotoView(
            imageProvider: NetworkImage(searchModel?.url ?? ''),
            loadingBuilder: (_, __) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              );
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 10,
            right: 16,
            child: DownloadButton(
              onTap: () => onDownload(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ImageCubit get cubit => throw UnimplementedError();

  onDownload() async {
    String url = searchModel?.url ?? '';
    if (url.isNotEmpty) {
      await DownloadHelper.downloadImage(url: url);
    }
  }
}

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
          await Future.delayed(Duration(seconds: 3));
          await widget.onTap?.call();
          _isDownloading = false;
          setState(() {});
        }
      },
      tooltip: 'Download this image',
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

// void showBottomSheetMenu(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.white,
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//               onTap: () => onDownload(),
//               child: Row(
//                 children: [
//                   Icon(Icons.download, size: 32),
//                   const SizedBox(width: 16),
//                   Text(
//                     LocaleKeys.saveToPhone,
//                     style: Theme.of(context).textTheme.headline6,
//                   ).tr(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
