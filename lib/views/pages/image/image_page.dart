import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_app/data/data.dart';
import 'package:photo_view/photo_view.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../base_page/base_page.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key, required this.cubit}) : super(key: key);
  final ImageCubit cubit;

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends CustomState<ImagePage, ImageCubit> {
  late SearchModel searchModel;

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        PhotoView(
          imageProvider: NetworkImage(searchModel.url ?? ''),
        ),
        Positioned(
          top: MediaQuery.of(context).viewPadding.top + 8,
          right: 8,
          child: IconButton(
            onPressed: () => showBottomSheetMenu(context),
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    return Hero(
      tag: searchModel.id ?? '',
      child: PhotoView(
        imageProvider: NetworkImage(searchModel.url ?? ''),
      ),
    );
  }

  void showBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.download, size: 32),
                  const SizedBox(width: 16),
                  Text(LocaleKeys.saveToPhone, style: Theme.of(context).textTheme.headline6,).tr(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void getPageSettings(Object? arguments) {
    if (arguments is SearchModel) {
      searchModel = arguments;
    }
  }

  @override
  ImageCubit get cubit => throw UnimplementedError();
}
