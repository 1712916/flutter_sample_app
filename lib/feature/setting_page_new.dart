import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/index.dart';
import '../resources/resources.dart';
import '../widgets/widgets.dart';
import 'base_page.dart';

class SettingNewPage extends StatefulWidget {
  const SettingNewPage({Key? key}) : super(key: key);

  @override
  _SettingNewPageState createState() => _SettingNewPageState();
}

class _SettingNewPageState extends StateTemplate<SettingNewPage> {
  @override
  Widget buildBody(BuildContext context) {
    final textColor = theme.textColor2;
    final iconColor = theme.iconColor;

    final String email = LKey.devInformation.tr(context: context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconTitleWidget(
            icon: Icon(
              Icons.favorite,
              color: iconColor,
              size: 20,
            ),
            title: LKey.description.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    LKey.appName,
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
                          '${LKey.version.tr()}: ${snapshot.data?.version ?? '---'}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                        );
                      }),
                  const SizedBox(height: 8),
                  Text(
                    LKey.descriptionDetail.tr(),
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
                      '${LKey.source.tr()}: https://portal.thatapicompany.com',
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
              Icons.settings,
              color: theme.iconColor,
              size: 20,
            ),
            title: LKey.settings.tr(),
          ),
          SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    tilePadding: EdgeInsets.only(right: 20),
                    // childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: ListTile(
                      title: LText(
                        LKey.language,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Icon(
                        Icons.language,
                        color: theme.iconColor,
                      ),
                    ),
                    children: [
                      ...LocaleUtils.locales.map(
                        (e) {
                          return ListTile(
                            leading: CountryFlag.fromLanguageCode(e.languageCode, width: 24, height: 16),
                            title: LText(LocaleUtils.lKeys[e.languageCode] ?? ''),
                            onTap: () {
                              context.setLocale(e);
                            },
                            trailing: context.locale == e ? const Icon(Icons.check) : null,
                          );
                        },
                      ),
                    ],
                  ),
                  ListTile(
                    title: LText(
                      LKey.darkMode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.dark_mode_outlined,
                      color: theme.iconColor,
                    ),
                    trailing: ValueListenableBuilder(
                        valueListenable: ThemeUtils.themeModeNotifier,
                        builder: (context, themMode, _) {
                          return Switch(
                            value: themMode == ThemeMode.dark,
                            activeColor: theme.highlightColor2,
                            inactiveTrackColor: theme.canvasColor,
                            onChanged: (bool value) {
                              ThemeUtils.toggleThemeMode();
                            },
                          );
                        }),
                  ),
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    tilePadding: EdgeInsets.only(right: 20),
                    // childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: ListTile(
                      title: LText(
                        LKey.storagePath,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Icon(
                        Icons.save_alt_outlined,
                        color: theme.iconColor,
                      ),
                    ),
                    children: [
                      ListTile(
                        subtitle: FutureBuilder(
                          future: DownloadHelper.storagePath(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.toString());
                            } else {
                              return Text('');
                            }
                          },
                        ),
                      ),
                    ],
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
            title: LKey.contact.tr(),
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
                              Toast.makeText(message: LKey.saveToPhone.tr());
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final textColor = theme.textColor2;
    return AppBar(
      title: Text(
        LKey.settings,
        style: theme.textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ).tr(),
      centerTitle: false,
      backgroundColor: theme.scaffoldBackgroundColor2,
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
