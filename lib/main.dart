import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/util/index.dart';
import 'dependencies/app_dependencies.dart';
import 'resources/resources.dart';
import 'resources/theme/theme_data.dart';
import 'routers/route.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  InternetCheckerHelper.connectivity.onConnectivityChanged.listen(InternetCheckerHelper.changeConnectivityResult);
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    SettingManager.loadSetting(),
    AppDependencies.init(),
    SimpleStorage().init(),
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

class _MaterialApp extends StatelessWidget {
  const _MaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeUtils.themeModeNotifier,
      builder: (context, ThemeMode themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          theme: ThemeUtils.lightTheme,
          darkTheme: ThemeUtils.darkTheme,
          themeMode: themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: RouteManager.mainPage,
          // home: TestGamePage(),
          onGenerateRoute: (settings) => RouteManager.getRoute(settings),
        );
      },
    );
  }
}
