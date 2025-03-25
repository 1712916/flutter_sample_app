import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../core/base/base_state.dart';
import '../../widgets/widgets.dart';
import 'cubit/image_list_cubit.dart';

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
              physics: const NeverScrollableScrollPhysics(),
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
                  child: AppShimmer(),
                );
              },
              itemCount: 24,
            );
          case LoadStatus.error:
            return Center(
              child: LText(LKey.haveAnError),
            );
          case LoadStatus.loaded:
            return RefreshIndicator(
              onRefresh: cubit.refreshData,
              edgeOffset: 120,
              backgroundColor: theme.highlightColor2,
              color: theme.iconTheme.color,
              child: GridView.builder(
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

                  if (index >= state.images!.length) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppShimmer(),
                    );
                  }

                  final item = state.images![index];
                  final image = item.url ?? '';
                  //print width height
                  return GestureDetector(
                    onTap: () {
                      cubit.showPageView(index);
                    },
                    child: Hero(
                      tag: index,
                      flightShuttleBuilder: (_, __, ___, ____, toHeroContext) {
                        return Material(
                          type: MaterialType.transparency,
                          child: toHeroContext.widget,
                        );
                      },
                      createRectTween: (begin, end) {
                        return MaterialRectCenterArcTween(begin: begin, end: end);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AppImage(
                          memCacheHeight: (item.height! / 3).toInt(),
                          memCacheWidth: (item.width! / 3).toInt(),
                          image: image,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: getLength(state.images?.length ?? 0),
              ),
            );
        }
      },
    );
  }
}

int getLength(int length) {
  final addLength = 15 - length % 3;

  return length + addLength;
}
