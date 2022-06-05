import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../../../routers/route.dart';
import '../../../utils/utils.dart';
import '../base_page/base_page.dart';
import 'home_content.dart';

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
  Widget buildContent(BuildContext context) {
    return HomeContent(
      scrollController: _scrollController,
    );
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        SettingManager.isMeow ? LocaleKeys.meowTitle : LocaleKeys.dogTitle,
        style: const TextStyle(color: Colors.black),
      ).tr(),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(RouteManager.settingPage);
          },
          icon: const Icon(
            Icons.settings,
            color: Colors.black,
          ),
        ),
      ],
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  HomeCubit get cubit => widget.cubit..initData();
}
