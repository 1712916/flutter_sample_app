import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../../cubits/cubits.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key, required this.initIndex});

  final int initIndex;

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ImageListCubit, ImageListState>(
      builder: (context, state) {
        final images = state.images ?? [];
        return PageView.builder(
          controller: controller,
          scrollDirection: Axis.vertical,
          itemCount: images.length,
          itemBuilder: (context, index) {
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
                      child: index == widget.initIndex
                          ? Hero(
                              tag: image,
                              flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: toContext.widget,
                                );
                              },
                              child: SizedBox(
                                width: 411.4,
                                child: CachedNetworkImage(
                                  width: 411.4,
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
                            )
                          : CachedNetworkImage(
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
          onPageChanged: (currentIndex) async {},
        );
      },
    );
  }
}
