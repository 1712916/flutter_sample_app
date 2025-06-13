import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/app_menu/cubit/app_menu_cubit.dart';
import 'package:meow_app/feature/favourite/cubit/favourite_cubit.dart';

import '../../core/base/index.dart';
import '../../widgets/widgets.dart';
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

    //todo: open later to config start
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     //show home widget
    //     autoPlaySortGame
    //       ..context = navKey.currentContext!
    //       ..pageController = _pageController
    //       ..runAutoPlayGame();
    //   });
    // });
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

                final image = images[pageIndex].url ?? '';
                return _buildImageCard(image, pageIndex);
              },
              onPageChanged: cubit.onPageChanged,
            );
        }
      },
    );
  }

  Widget _buildImageCard(String? image, int index) {
    if (image == null) return SizedBox.shrink();

    return Center(
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
                  child: AppImage(image: image),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
