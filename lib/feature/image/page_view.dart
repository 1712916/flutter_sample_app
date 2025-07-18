import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/app_menu/cubit/app_menu_cubit.dart';
import 'package:meow_app/feature/favourite/cubit/favourite_cubit.dart';

import '../../core/base/index.dart';
import '../../core/util/image_util.dart';
import '../../data/data.dart';
import '../../main.dart';
import '../../widgets/widgets.dart';
import '../auto_play/auto_play.dart';
import '../auto_play/auto_play_sort_game.dart';
import '../base_page.dart';
import '../favourite/favourite_wrapper.dart';
import 'cubit/image_list_cubit.dart';
import 'detail_image_page.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key});

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends StateTemplate<ImagePageView> {
  ImageListCubit get cubit => context.read<ImageListCubit>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: cubit.currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (autoPlayGameNotifier.value) {
        Future.delayed(const Duration(seconds: 1), () {
          //show home widget
          autoPlaySortGame
            ..context = navKey.currentContext!
            ..pageController = _pageController
            ..runAutoPlayGame();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return BlocBuilder<ImageListCubit, ImageListState>(
      builder: (context, state) {
        switch (state.loadStatus) {
          case null:
          case LoadStatus.init:
          case LoadStatus.loading:
            return Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: AppShimmer(),
                ),
              ),
            );
          case LoadStatus.error:
            return Center(child: LText(LKey.haveAnError));
          case LoadStatus.loaded:
            final images = state.images ?? [];

            final itemCount = images.length;

            return PageView.builder(
              controller: _pageController,
              scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, pageIndex) {
                if (pageIndex >= itemCount - 1) {
                  cubit.loadMore(imageListLimit);
                }

                return _buildImageCard(images[pageIndex], pageIndex);
              },
              onPageChanged: cubit.onPageChanged,
            );
        }
      },
    );
  }

  Widget _buildImageCard(SearchModel model, int index) {
    final image = model.url;
    if (image == null) return SizedBox.shrink();

    return ZoomWidget(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Hero(
            tag: index,
            createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: FavouriteWrapper(
                  onFavourite: () {
                    context.read<FavouriteCubit>().addFavouriteItem(image);
                  },
                  child: GestureDetector(
                    onTap: () {
                      final AppMenuCubit appMenuCubit = context.read<AppMenuCubit>();
                      appMenuCubit.hideAll();
                      final ImageListCubit imageListCubit = context.read<ImageListCubit>();
                      DetailImagePage(url: image, heroTag: '$index')
                          .show(imageListCubit.navKey.currentContext!, rootNavigator: false)
                          .whenComplete(appMenuCubit.previousMenu);
                    },
                    child: AppImage(
                        memCacheWidth: ImageUtil.getCachedImageSizeFrom(
                          model.width ?? 1500,
                          type: ImageViewSizeType.medium,
                        ),
                        image: image),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
