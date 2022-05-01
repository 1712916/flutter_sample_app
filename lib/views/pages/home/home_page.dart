import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../base_page/base_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.cubit}) : super(key: key);

  final HomeCubit cubit;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends CustomState<HomePage, HomeCubit> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget buildContent(BuildContext context) {
    return const _HomeContent();
  }

  @override
  buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        switch (state.loadStatus) {
          case LoadStatus.init:
            return const SizedBox();
          case LoadStatus.loaded:
            return FloatingActionButton(onPressed: () {
              context.read<HomeCubit>().loadMore();
            });
          default:
            return const SizedBox();
        }
      },
    );
  }

  @override
  HomeCubit get cubit => widget.cubit..initData();
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

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
            return ListView.builder(
              itemCount: contents?.length ?? 0,
              itemBuilder: (context, index) {
                return Text(contents?[index] ?? '');
              },
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
