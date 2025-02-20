import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../cubits/cubits.dart';
import '../../../resources/resources.dart';
import '../../../routers/route.dart';
import '../../../widgets/widgets.dart';
import '../base_page/base_page.dart';
import '../pages.dart';

class SettingNewPage extends StatefulWidget {
  const SettingNewPage({Key? key, required this.cubit}) : super(key: key);
  final SettingsCubit cubit;

  @override
  _SettingNewPageState createState() => _SettingNewPageState();
}

class _SettingNewPageState extends CustomState<SettingNewPage, SettingsCubit> {
  @override
  Widget buildContent(BuildContext context) {
    final textColor = theme.textColor2;
    final String email = 'freelancer.vinhnt@gmail.com';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconTitleWidget(
            icon: Icon(
              Icons.favorite,
              color: theme.iconColor,
              size: 20,
            ),
            title: LocaleKeys.description.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meow App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        return Text(
                          '${LocaleKeys.version.tr()}: ${snapshot.data?.version ?? '---'}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                        );
                      }),
                  const SizedBox(height: 8),
                  Text(
                    LocaleKeys.descriptionDetail.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      launchUrl(Uri.parse('https://portal.thatapicompany.com'));
                    },
                    child: Text(
                      '${LocaleKeys.source.tr()}: https://portal.thatapicompany.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.lightBlueAccent,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          IconTitleWidget(
            icon: Icon(
              Icons.mail,
              color: theme.iconColor,
              size: 20,
            ),
            title: LocaleKeys.contact.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          //copy to clipboard
                          Clipboard.setData(ClipboardData(text: email)).then(
                            (value) {
                              Toast.makeText(message: LocaleKeys.saveToPhone.tr());
                            },
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          color: textColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    final textColor = theme.iconColor;
    return AppBar(
      title: Text(
        LocaleKeys.settings,
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ).tr(),
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: textColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future onSave() async {
    await LoadingDialog.doSomething(
      context,
      call: () async {
        return await cubit.onSave();
      },
      onDone: (isSaved) async {
        if (isSaved is bool && isSaved) {
          Toast.makeText(message: LocaleKeys.savedSettings.tr());
          await Future.delayed(const Duration(milliseconds: 300));
          Navigator.of(context).pushNamedAndRemoveUntil(RouteManager.home, (route) => false);
        } else {
          Toast.makeText(message: LocaleKeys.savedSettingsFailure.tr());
        }
      },
    );
  }

  @override
  SettingsCubit get cubit => widget.cubit;
}

class PatternListWidget extends StatefulWidget {
  const PatternListWidget({
    Key? key,
    required this.initIndex,
    this.onChange,
  }) : super(key: key);
  final int initIndex;
  final Function(int)? onChange;

  @override
  _PatternListWidgetState createState() => _PatternListWidgetState();
}

class _PatternListWidgetState extends State<PatternListWidget> {
  late final ValueNotifier<int> index;
  late final FixedExtentScrollController controller;

  @override
  void initState() {
    index = ValueNotifier(widget.initIndex);
    controller = FixedExtentScrollController(initialItem: widget.initIndex);
    super.initState();
  }

  @override
  void dispose() {
    index.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: index,
          builder: (context, value, _) {
            return Text(
              '${LocaleKeys.currentPattern.tr()}: $value',
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.6,
          width: MediaQuery.of(context).size.width,
          child: RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView.useDelegate(
              physics: const FixedExtentScrollPhysics(),
              controller: controller,
              onSelectedItemChanged: (value) {
                index.value = value;
                widget.onChange?.call(value);
              },
              itemExtent: MediaQuery.of(context).size.width * 0.5,
              childDelegate: ListWheelChildLoopingListDelegate(
                  children: GridPattern.list
                      .map(
                        (e) => RotatedBox(
                          quarterTurns: 1,
                          child: PresentationPage(
                            gridPattern: e.gridPattern,
                            length: e.length,
                            crossAxisCount: e.crossAxisCount,
                          ),
                        ),
                      )
                      .toList()),
            ),
          ),
        ),
      ],
    );
  }
}

class IconTitleWidget extends StatelessWidget {
  const IconTitleWidget({super.key, required this.icon, required this.title});

  final Widget icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).iconColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
