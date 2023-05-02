import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';

abstract class CustomState<T extends StatefulWidget, C extends Cubit> extends State<T> {
  bool isBody = false;

  C get cubit;

  PreferredSizeWidget? buildAppbar(BuildContext context) => null;

  Widget buildContent(BuildContext context) => const SizedBox.shrink();

  bool isFirstLoad = true;

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
              appBar: buildAppbar(context),
              body: buildContent(context),
              floatingActionButton: buildFloatingActionButton(context),
            ),
    );
  }

  void eventListener(BaseEvent event) {}

  buildFloatingActionButton(BuildContext context) {}
}
