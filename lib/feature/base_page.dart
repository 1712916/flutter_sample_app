import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../core/base/index.dart';

abstract class CustomState<T extends StatefulWidget, C extends Cubit> extends State<T> {
  bool isBody = false;

  C get cubit;

  PreferredSizeWidget? buildAppbar(BuildContext context) => null;

  Widget buildContent(BuildContext context) => const SizedBox.shrink();

  bool isFirstLoad = true;

  ThemeData get theme => Theme.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirstLoad && mounted) {
      getPageSettings(ModalRoute.of(context)!.settings.arguments);
      isFirstLoad = false;
    }
  }

  void getPageSettings(Object? arguments) {}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: isBody
          ? buildContent(context)
          : Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor2,
              appBar: buildAppbar(context),
              body: buildContent(context),
              floatingActionButton: buildFloatingActionButton(context),
            ),
    );
  }

  void eventListener(BaseEvent event) {}

  buildFloatingActionButton(BuildContext context) {}
}

mixin StatelessTemplate on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget buildBody(BuildContext context) {
    return const Placeholder();
  }
}

class StateTemplate<T extends StatefulWidget> extends State<T> {
  bool get isScaffold => true;

  ThemeData get theme => Theme.of(context);

  Color get backgroundColor => theme.scaffoldBackgroundColor2;

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  bool get isPortrait => !isLandscape(context);

  @override
  Widget build(BuildContext context) {
    if (isScaffold) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: buildAppBar(context),
        body: buildBody(context),
        floatingActionButton: buildFloatingActionButton(context),
      );
    } else {
      return buildBody(context);
    }
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget buildBody(BuildContext context) {
    return const Placeholder();
  }

  Widget? buildFloatingActionButton(BuildContext context) => null;
}

mixin LoadingState<T extends StatefulWidget> on State<T> {
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(false);

  void showLoading() {
    _loadingNotifier.value = true;
  }

  void hideLoading() {
    _loadingNotifier.value = false;
  }

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        super.build(context),
        ValueListenableBuilder<bool>(
          valueListenable: _loadingNotifier,
          builder: (_, bool loading, __) {
            return loading ? buildLoading(context) : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget buildLoading(BuildContext context) {
    return const SizedBox();
  }
}
