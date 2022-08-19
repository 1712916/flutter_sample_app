import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../../../data/data.dart';
import '../base_page/base_page.dart';
import 'image_page.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({Key? key, required this.cubit}) : super(key: key);

  final ImageListCubit cubit;

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends CustomState<ImageListPage, ImageListCubit> {
  bool _isLoadMore = false;

  @override
  void getPageSettings(Object? arguments) {
    if (arguments is List<SearchModel>) {
      cubit.initData(arguments);
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return BlocBuilder<ImageListCubit, ImageListState>(
      builder: (context, state) {
        final images = state.images ?? [];
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ImagePage(
              key: UniqueKey(),
              cubit: ImageCubit(),
              searchModel: images[index],
            );
          },
          onPageChanged: (currentIndex) async {
            if (!_isLoadMore) {
              _isLoadMore = true;
              if (images.length - 2 == currentIndex) {
                await cubit.loadMore(imageListLimit);
              }
              _isLoadMore = false;
            }
          },
        );
      },
    );
  }

  @override
  ImageListCubit get cubit => widget.cubit;
}
