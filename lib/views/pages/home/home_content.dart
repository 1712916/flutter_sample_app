import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../../../routers/route.dart';
import '../../../utils/utils.dart';
import '../../views.dart';
import 'load_more.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key, required this.scrollController}) : super(key: key);
  final ScrollController scrollController;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels >= (widget.scrollController.position.maxScrollExtent * 1)) {
        context.read<HomeCubit>().loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        switch (state.loadStatus) {
          case LoadStatus.init:
            return const SizedBox();
          case LoadStatus.loading:
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            );
          case LoadStatus.loaded:
            final contents = state.contents;
            return ListView(
              controller: widget.scrollController,
              physics: const RangeMaintainingScrollPhysics(),
              children: [
                GridView.custom(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: GridPattern.list[SettingManager.patternIndex!].crossAxisCount,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    repeatPattern: QuiltedGridRepeatPattern.same,
                    pattern: GridPattern.list[SettingManager.patternIndex!].gridPattern,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          RouteManager.imageListPage,
                          arguments: contents!.sublist(index, (index + 10) < contents.length ? (index + 10) : 0),
                        );
                      },
                      child: Image.network(
                        contents?[index].url ?? '',
                        fit: BoxFit.cover,
                        loadingBuilder: (_, widget, ___) => ColoredBox(color: Colors.grey.shade200, child: widget,),
                        errorBuilder: (_, __, ___) => ColoredBox(color: Colors.grey.shade200),
                      ),
                    ),
                    // (context, index) => CachedNetworkImage(
                    //   useOldImageOnUrlChange: true,
                    //   placeholder: (context, url) => Container(
                    //     color: Colors.grey.withOpacity(0.5),
                    //   ),
                    //   imageUrl: contents?[index].url ?? '',
                    //   fit: BoxFit.cover,
                    // ),
                    childCount: contents?.length ?? 0,
                  ),
                  cacheExtent: 9999,
                ),
                const LoadMoreCircular(),
              ],
            );
          case LoadStatus.error:
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(LocaleKeys.haveAnError).tr(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.read<HomeCubit>().initData(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: context.read<ThemeCubit>().getColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(LocaleKeys.retry).tr(),
                    ),
                  ),
                ],
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}