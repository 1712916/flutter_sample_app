import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:shimmer/shimmer.dart';

import '../../../cubits/cubits.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key});

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  PageController? get controller => cubit.pageController;

  ImageListCubit get cubit => context.read<ImageListCubit>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ImageListCubit, ImageListState>(
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
                      child: Shimmer.fromColors(
                        baseColor: theme.imagePlaceholderColor,
                        highlightColor: Colors.white,
                        child: Container(
                          color: theme.imagePlaceholderColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          case LoadStatus.error:
            return Center(
              child: Text('Error'),
            );
          case LoadStatus.loaded:
            final images = state.images ?? [];
            return PageView.builder(

              controller: controller,
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
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Container(
                                color: theme.imagePlaceholderColor,
                              );
                            },
                            // fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: (currentIndex) async {
                cubit.currentIndex = currentIndex;
              },
            );
        }
      },
    );
  }
}
