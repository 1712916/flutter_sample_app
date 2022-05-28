import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../cubits/cubits.dart';
import '../../routers/route.dart';
import 'base_page/base_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key,required this.cubit}) : super(key: key);
  final MainCubit cubit;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends CustomState<MainPage, MainCubit>  with SingleTickerProviderStateMixin {

  @override
  Widget buildContent(BuildContext context) {
    return PageView(
      children: [
        GetIt.I.get(instanceName: RouteManager.home),
      ],
    );
  }

  @override
  get cubit => widget.cubit;
}
