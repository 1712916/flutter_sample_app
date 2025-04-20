import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';

import 'core/persistence/isar_storage.dart';
import 'core/util/index.dart';
import 'dependencies/app_dependencies.dart';
import 'feature/app_menu/cubit/app_menu_cubit.dart';
import 'feature/background_worker/background_worker.dart';
import 'feature/favourite/cubit/favourite_cubit.dart';
import 'feature/firebase/firebase.dart';
import 'feature/game/cubit/game_setting_cubit.dart';
import 'feature/home_widget/home_widget_page.dart';
import 'feature/image/cubit/image_list_cubit.dart';
import 'feature/showcase/showcase_util.dart';
import 'resources/resources.dart';
import 'resources/theme/theme_data.dart';
import 'routers/route.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final AppMenuCubit appMenuCubit = GetIt.I.get();

void main() async {
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

  Bloc.observer = AppBlocObserver();

  FlutterNativeSplash.remove();

  runApp(
    EasyLocalization(
      child: const MyApp(),
      supportedLocales: LocaleUtils.locales,
      path: LocaleUtils.path,
    ),
  );
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
          ),
        );
      },
    );
  }
}
