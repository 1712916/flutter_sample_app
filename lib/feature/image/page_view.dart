import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../core/base/index.dart';
import '../../widgets/widgets.dart';
import 'cubit/image_list_cubit.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key});

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  ImageListCubit get cubit => context.read<ImageListCubit>();

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: cubit.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor2,
      body: BlocBuilder<ImageListCubit, ImageListState>(
        builder: (context, state) {
          switch (state.loadStatus) {
            case null:
            case LoadStatus.init:
            case LoadStatus.loading:
              return Align(
                alignment: Alignment(0, -0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: AppShimmer(),
                      ),
                    ),
                  ],
                ),
              );
            case LoadStatus.error:
              return Center(
                child: LText(LKey.haveAnError),
              );
            case LoadStatus.loaded:
              final images = state.images ?? [];
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  if (index == images.length - 1) {
                    cubit.loadMore(imageListLimit);
                  }

                  final image = images[index].url ?? '';

                  return Align(
                    alignment: Alignment(0, -0.2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: index,
                          createRectTween: (begin, end) {
                            return MaterialRectCenterArcTween(begin: begin, end: end);
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: AppImage(image: image),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onPageChanged: cubit.setCurrentIndex,
              );
          }
        },
      ),
    );
  }
}
