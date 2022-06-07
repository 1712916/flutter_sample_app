import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../cubits/cubits.dart';
import '../../../data/data.dart';
import '../../../helpers/helpers.dart';
import '../../../widgets/widgets.dart';
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
            bottom: MediaQuery.of(context).size.height / 6,
            right: 16,
            child: Column(
              children: [
                DownloadButton(
                  key: UniqueKey(),
                  icon: Icons.share,
                  onTap: () => onShare(),
                ),
                const SizedBox(height: 10),
                DownloadButton(
                  key: UniqueKey(),
                  onTap: () => onDownload(),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: const BackButton(
              color: Colors.white,
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

  onShare() async {
    String url = searchModel?.url ?? '';
    if (url.isNotEmpty) {
      await ShareHelper.shareImage(url: url);
    }
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
