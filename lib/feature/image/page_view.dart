import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/app_menu/cubit/app_menu_cubit.dart';
import 'package:meow_app/feature/favourite/cubit/favourite_cubit.dart';

import '../../core/index.dart';
import '../../core/util/image_util.dart';
import '../../data/data.dart';
import '../../main.dart';
import '../../widgets/widgets.dart';
import '../auto_play/auto_play.dart';
import '../auto_play/auto_play_memory_game.dart';
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

  final ValueNotifier<int> _pointerCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _scaleEnableNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: cubit.currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check for enhanced auto-play (supports different game types)
      if (enhancedAutoPlayGameNotifier.isEnabled) {
        Future.delayed(const Duration(seconds: 1), () {
          final gameType = enhancedAutoPlayGameNotifier.value!;
          switch (gameType) {
            case AutoPlayGameType.sortGame:
              autoPlaySortGame
                ..context = navKey.currentContext!
                ..pageController = _pageController
                ..runAutoPlayGame();
              break;
            case AutoPlayGameType.memoryGame:
              // Use the auto play matching game from auto_play_memory_game.dart
              final memoryGameAutoPlay = AutoPlayMemoryGame()
                ..context = navKey.currentContext!
                ..pageController = _pageController;
              memoryGameAutoPlay.runAutoPlayGame();
              break;
          }
        });
      }
    });

    _pointerCountNotifier.addListener(_onPointerCountChanged);
  }

  void _onPointerCountChanged() {
    final pointerCount = _pointerCountNotifier.value;
    if (pointerCount < 2) {
      _scaleEnableNotifier.value = false;
    } else {
      _scaleEnableNotifier.value = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pointerCountNotifier.removeListener(_onPointerCountChanged);
    _pointerCountNotifier.dispose();
    _scaleEnableNotifier.dispose();
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

            return Listener(
              onPointerDown: (_) {
                if (_pointerCountNotifier.value < 2) _pointerCountNotifier.value++;
              },
              onPointerUp: (_) {
                if (_pointerCountNotifier.value > 0) _pointerCountNotifier.value--;
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: _scaleEnableNotifier,
                builder: (context, disableScroll, __) {
                  return PageView.builder(
                    dragStartBehavior: DragStartBehavior.down,
                    controller: _pageController,
                    scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
                    physics: disableScroll ? const NeverScrollableScrollPhysics() : null,
                    itemCount: itemCount,
                    itemBuilder: (context, pageIndex) {
                      if (pageIndex >= itemCount - 1) {
                        cubit.loadMore(imageListLimit);
                      }

                      return _buildImageCard(images[pageIndex], pageIndex);
                    },
                    onPageChanged: cubit.onPageChanged,
                  );
                },
              ),
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
