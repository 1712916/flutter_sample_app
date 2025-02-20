import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:shimmer/shimmer.dart';

import '../../../cubits/cubits.dart';

class ImageGridView extends StatefulWidget {
  const ImageGridView({super.key});

  @override
  State<ImageGridView> createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImageListCubit>();
    final theme = Theme.of(context);
    return BlocBuilder<ImageListCubit, ImageListState>(
      builder: (context, state) {
        switch (state.loadStatus) {
          case null:
          case LoadStatus.init:
          case LoadStatus.loading:
            return GridView.builder(
              padding: const EdgeInsets.only(top: 120, bottom: 80),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Shimmer.fromColors(
                    baseColor: theme.imagePlaceholderColor,
                    highlightColor: Colors.white,
                    child: Container(
                      color: theme.imagePlaceholderColor,
                    ),
                  ),
                );
              },
              itemCount: 24,
            );
          case LoadStatus.error:
            return Center(
              child: Text('Error'),
            );
          case LoadStatus.loaded:
            return GridView.builder(
              padding: const EdgeInsets.only(top: 120, bottom: 80),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index == state.images!.length - 1) {
                  cubit.loadMore(imageListLimit);
                }

                final item = state.images![index];
                final image = item.url ?? '';
                //print width height
                print('width: ${item.width} height: ${item.height}');
                return GestureDetector(
                  onTap: () {
                    cubit.showPageView(index);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: image,
                      child: SizedBox(
                        width: 135.8,
                        child: CachedNetworkImage(
                          memCacheHeight: (item.height! / 3).toInt(),
                          memCacheWidth: (item.width! / 3).toInt(),
                          imageUrl: image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return Container(
                              color: theme.imagePlaceholderColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: state.images?.length ?? 0,
            );
        }
      },
    );
  }
}
