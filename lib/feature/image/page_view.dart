import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/app_menu/cubit/app_menu_cubit.dart';
import 'package:meow_app/feature/favourite/cubit/favourite_cubit.dart';
import 'package:meow_app/main.dart';

import '../../core/base/index.dart';
import '../../widgets/widgets.dart';
import '../base_page.dart';
import '../favourite/favourite_wrapper.dart';
import 'cubit/image_list_cubit.dart';
import 'detail_image_page.dart';

final GlobalKey<ImagePageViewState> imagePageViewKey = GlobalKey<ImagePageViewState>();

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key});

  @override
  State<ImagePageView> createState() => ImagePageViewState();
}

class ImagePageViewState extends StateTemplate<ImagePageView> {
  ImageListCubit get cubit => context.read<ImageListCubit>();
  late PageController _pageController;
  int swipeCount = 0;

  void nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: cubit.currentIndex);
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

                if (swipeCount != 0 && swipeCount % 5 == 0) {
                  swipeCount = 0;
                  adsCubit.showAds();
                  return const AdsCard();
                }

                swipeCount++;

                if (adsCubit.state.isShow) {
                  adsCubit.hideAds();
                }

                final image = images[pageIndex].url ?? '';
                return _buildImageCard(image, pageIndex);
              },
              onPageChanged: (index) {
                cubit.onPageChanged(index);
              },
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

class AdsCard extends StatelessWidget {
  const AdsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Placeholder(),
          ),
        ),
      ),
    );
  }
}
