import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/core/sound/music_manager.dart';
import 'package:meow_app/feature/game/sound/game_sound_manager.dart';
import 'package:meow_app/widgets/text.dart';

import 'core/persistence/isar_storage.dart';
import 'core/util/index.dart';
import 'dependencies/app_dependencies.dart';
import 'feature/app_menu/cubit/app_menu_cubit.dart';
import 'feature/auto_play/auto_play_sort_game.dart';
import 'feature/background_worker/background_worker.dart';
import 'feature/favourite/cubit/favourite_cubit.dart';
import 'feature/firebase/firebase.dart';
import 'feature/game/cubit/game_setting_cubit.dart';
import 'feature/home_widget/home_widget_page.dart';
import 'feature/image/cubit/image_list_cubit.dart';
import 'feature/showcase/showcase_util.dart';
import 'resources/theme/theme_data.dart';
import 'routers/route.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final AppMenuCubit appMenuCubit = GetIt.I.get();

Future main() async {
  await initApp();

  runApp(
    EasyLocalization(
      child: const MyApp(),
      supportedLocales: LocaleUtils.locales,
      path: LocaleUtils.path,
    ),
  );
}

Future initApp() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await configFirebase();
  InternetCheckerHelper.connectivity.onConnectivityChanged.listen(InternetCheckerHelper.changeConnectivityResult);
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    SettingManager.loadSetting(),
    AppDependencies.init(),
    SimpleStorage().init().whenComplete(() => Future.wait([ThemeUtils.initThemeMode(), ShowcaseUtil.init()])),
    IsarDatabase().initialize(),
    AppHomeWidget.init(),
    BackgroundWorker.init().whenComplete(
      () {
        BackgroundWorker.registerLoadHomeWidgetData();
      },
    ),
  ]);

  // Initialize the music manager to check and download music files
  final musicManager = MusicManager();
  await musicManager.initialize();

  // Initialize game sound manager without starting music playback
  final gameSoundManager = GameSoundManager();
  await gameSoundManager.initialize();

  Bloc.observer = AppBlocObserver();

  FlutterNativeSplash.remove();
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      log('${bloc.runtimeType} $change');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const _MaterialApp();
  }
}

class _MaterialApp extends StatefulWidget {
  const _MaterialApp({Key? key}) : super(key: key);

  @override
  State<_MaterialApp> createState() => _MaterialAppState();
}

class _MaterialAppState extends State<_MaterialApp> {
  final ImageListCubit imageListCubit = GetIt.I.get();
  final FavouriteCubit favouriteCubit = GetIt.I.get();
  final GameSettingCubit gameSettingCubit = GetIt.I.get();

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    final fragment = uri.fragment; // VD: /invite
    final queryParams = uri.queryParameters;

    print('📲 Deep link opened: $fragment');
    print('📦 Query params: $queryParams');

    if (fragment.isEmpty) {
      navKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      navKey.currentState?.pushNamed(fragment, arguments: queryParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeUtils.themeModeNotifier,
      builder: (context, ThemeMode themeMode, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => imageListCubit),
            BlocProvider(create: (_) => favouriteCubit),
            BlocProvider(create: (_) => gameSettingCubit),
            BlocProvider(create: (_) => appMenuCubit),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navKey,
            theme: ThemeUtils.lightTheme,
            darkTheme: ThemeUtils.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            initialRoute: RouteManager.mainPage,
            onGenerateRoute: (settings) => RouteManager.getRoute(settings),
            builder: (context, child) {
              return ValueListenableBuilder(
                valueListenable: autoPlayGameNotifier,
                builder: (context, autoMode, _) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        children: [
                          Expanded(child: child ?? const SizedBox.shrink()),
                          if (autoMode)
                            Material(
                              color: context.appTheme.scaffoldBackgroundColor2,
                              child: SafeArea(
                                top: false,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        HugeIcons.strokeRoundedRobotic,
                                        color: context.appTheme.iconColor,
                                      ),
                                      const SizedBox(width: 8),
                                      LText(LKey.autoPlayMode),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (autoMode) Material(color: Colors.white10),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
