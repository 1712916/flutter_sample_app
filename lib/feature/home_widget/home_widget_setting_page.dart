import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/radio.dart';
import 'package:meow_app/widgets/toast.dart';

import '../../core/util/background_worker.dart';
import '../../data/data_provider/remote/search_service.dart';
import '../../resources/icon/icon_path.dart';
import '../../resources/string/string.dart';
import '../../widgets/text.dart';
import '../game_sort/game_setting_page.dart';
import '../image/cubit/image_list_cubit.dart';
import 'home_widget_page.dart';

//by hour
final List<int> refreshTimes = [2, 4, 6, 8, 12, 24];

class HomeWidgetSettingPage extends StatefulWidget {
  const HomeWidgetSettingPage({super.key});

  @override
  State<HomeWidgetSettingPage> createState() => HomeWidgetSettingPageState();
}

class HomeWidgetSettingPageState extends State<HomeWidgetSettingPage> {
  //create static keys to store settings
  static const String isCatKey = 'home_widget/isCat';
  static const String refreshTimeKey = 'home_widget/refreshTime';

  ThemeData get theme => Theme.of(context);

  final SimpleStorage storage = SimpleStorage();

  ImageListCubit get cubit => context.read<ImageListCubit>();

  bool isCat = true;
  int refreshTime = refreshTimes.first;

  void setIsCat(bool value) async {
    if (value == isCat) return;

    setState(() {
      isCat = value;
    });

    storage.saveBool(isCatKey, value);

    _onResetImage();

    Toast.makeText(
      toastLength: Toast.LENGTH_LONG,
      message: LKey.changeHomeWidgetToast.tr(
        namedArgs: {"type": value ? TextResource.cat : TextResource.dog},
      ),
    );
  }

  Future _onResetImage() async {
    String newUrl = '';

    if (SettingManager.isMeow == isCat) {
      // cubit.randomImage;
      newUrl = cubit.randomImage ?? '';
    } else {
      //call api to get a random image
      final rs = await SearchService.searchImages(
        isMeow: isCat,
        limit: 1,
        page: 1,
      );
      final image = rs.data?.firstOrNull;
      newUrl = image?.url ?? '';
    }

    AppHomeWidget.updateWidget(HomeWidgetData(url: newUrl));
  }

  void setRefreshTime(int value) {
    if (value == refreshTime) return;

    setState(() {
      refreshTime = value;
    });
    storage.saveInt(refreshTimeKey, value);
    BackgroundWorker.registerLoadHomeWidgetData(refreshTime);
    Toast.makeText(
      toastLength: Toast.LENGTH_LONG,
      message: LKey.changeRefreshTimeToast.tr(
        namedArgs: {"time": '$value'},
      ),
    );
  }

  void onRefreshWidgetTap() {
    _onResetImage();
    Toast.makeText(
      toastLength: Toast.LENGTH_LONG,
      message: LKey.refreshAppWidgetToast.tr(),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      isCat = await storage.getBool(isCatKey) ?? true;
      refreshTime = await storage.getInt(refreshTimeKey) ?? refreshTimes.first;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = theme.textColor2;
    final iconColor = theme.iconColor;
    return Scaffold(
      appBar: AppBar(
        title: LText(LKey.appWidget),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IconTitleWidget(
            icon: Icon(
              Icons.category_outlined,
              color: iconColor,
              size: 20,
            ),
            title: LKey.catOrDog.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () {
                      setIsCat(true);
                    },
                    leading: SvgPicture.asset(
                      IconPath.cat,
                      color: theme.iconColor,
                      width: 24,
                      height: 24,
                    ),
                    title: Text(
                      TextResource.cat,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: AppRadio(isSelected: isCat),
                  ),
                  ListTile(
                    onTap: () {
                      setIsCat(false);
                    },
                    leading: SvgPicture.asset(
                      IconPath.dog,
                      color: theme.iconColor,
                      width: 24,
                      height: 24,
                    ),
                    title: Text(
                      TextResource.dog,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: AppRadio(isSelected: !isCat),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          IconTitleWidget(
            icon: Icon(
              Icons.loop,
              color: iconColor,
              size: 20,
            ),
            title: LKey.widgetRefreshTime.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...refreshTimes.map(
                    (time) => ListTile(
                      onTap: () {
                        setRefreshTime(time);
                      },
                      title: Text(
                        '$time ${LKey.hour.tr()}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: AppRadio(isSelected: time == refreshTime),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          IconTitleWidget(
            icon: Icon(
              Icons.explore_outlined,
              color: iconColor,
              size: 20,
            ),
            title: LKey.other.tr(),
          ),
          SizedBox(height: 4),
          Card(
              color: theme.cardColor2,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      AppHomeWidget.requestPinWidget();
                    },
                    leading: Icon(
                      Icons.widgets_outlined,
                      color: iconColor,
                      size: 24,
                    ),
                    title: Text(
                      LKey.pin.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: onRefreshWidgetTap,
                    leading: Icon(
                      Icons.refresh,
                      color: iconColor,
                      size: 24,
                    ),
                    title: Text(
                      LKey.refresh.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(height: 16), // I
        ],
      ),
    );
  }
}
