import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/routers/route.dart';
import 'package:flutter_sample_app/views/pages/image/image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../base_page/base_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.cubit}) : super(key: key);

  final HomeCubit cubit;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends CustomState<HomePage, HomeCubit> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget buildContent(BuildContext context) {
    return _HomeContent(
      scrollController: _scrollController,
    );
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        LocaleKeys.title,
        style: TextStyle(color: Colors.black),
      ).tr(),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  HomeCubit get cubit => widget.cubit..initData();
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key, required this.scrollController}) : super(key: key);
  final ScrollController scrollController;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels >= (widget.scrollController.position.maxScrollExtent * 0.8)) {
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
              child: CircularProgressIndicator(),
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
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    repeatPattern: QuiltedGridRepeatPattern.same,
                    pattern: gridPattern,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteManager.imagePage, arguments: contents![index],);
                      },
                      child: Image.network(
                        contents?[index].url ?? '',
                        fit: BoxFit.cover,
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
          default:
            return const SizedBox();
        }
      },
    );
  }
}

class LoadMoreCircular extends StatelessWidget {
  const LoadMoreCircular({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.loaded && state.loadingMore == true) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
