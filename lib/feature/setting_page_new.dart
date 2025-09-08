import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/index.dart';
import '../core/util/app_store_review.dart';
import '../routers/route.dart';
import '../widgets/widgets.dart';
import 'auto_play/auto_play_selection_widget.dart';
import 'base_page.dart';
import 'favourite/count_favourite_widget.dart';
import 'onboarding/onboarding_util.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconTitleWidget(
            icon: Icon(
              Icons.bookmark_add,
              color: iconColor,
              size: 20,
            ),
            title: LKey.explore.tr(),
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
                      goToFavouritePage();
                    },
                    title: LText(
                      LKey.favourite,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: CountFavouriteWidget2(),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      goToAppWidgetSettingPage();
                    },
                    title: LText(
                      LKey.appWidget,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.widgets_outlined,
                      color: theme.iconColor,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16), // I
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
                  FutureBuilder<bool>(
                    initialData: false,
                    future: InAppReviewUtil().isAvailable(),
                    builder: (context, snapshot) {
                      // Check if in-app review is available
                      if (!snapshot.hasData || !(snapshot.data ?? false)) {
                        return const SizedBox();
                      }
                      return ListTile(
                        title: LText(
                          LKey.reviewApp,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        leading: Icon(
                          Icons.star_border_outlined,
                          color: theme.iconColor,
                        ),
                        onTap: () {
                          InAppReviewUtil().openStoreListing();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16), // IconTitleWidget
          IconTitleWidget(
            icon: Icon(
              Icons.live_help,
              color: theme.iconColor,
              size: 20,
            ),
            title: LKey.guide.tr(),
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
                    title: LText(
                      LKey.autoPlay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.play_circle_outlined,
                      color: theme.iconColor,
                    ),
                    onTap: () {
                      // Show new auto-play selection dialog
                      AutoPlaySelectionWidget().show(context);
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Debug section (only visible in debug mode)
          if (kDebugMode) ...[
            IconTitleWidget(
              icon: Icon(
                Icons.bug_report,
                color: iconColor,
                size: 20,
              ),
              title: 'Debug Options',
            ),
            SizedBox(height: 4),
            Card(
              color: theme.cardColor2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: LText(
                        'Reset Onboarding',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: LText(
                        'Show onboarding screen on next app launch',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      leading: Icon(
                        Icons.refresh,
                        color: theme.iconColor,
                      ),
                      onTap: () async {
                        await OnboardingUtil.resetOnboarding();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Onboarding reset. Restart the app to see onboarding.'),
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          SizedBox(height: 16), // Ic
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
