import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:meow_app/views/pages/game/test_game_page.dart';

import 'cubits/cubits.dart';
import 'dependencies/app_dependencies.dart';
import 'helpers/helpers.dart';
import 'resources/theme/theme_data.dart';
import 'routers/route.dart';
import 'utils/utils.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  InternetCheckerHelper.connectivity.onConnectivityChanged.listen(InternetCheckerHelper.changeConnectivityResult);
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    SettingManager.loadSetting(),
    AppDependencies.init(),
  ]);
  BlocOverrides.runZoned(
    () async {
      FlutterNativeSplash.remove();
      runApp(
        EasyLocalization(
          child: const MyApp(),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('vi', 'VN'),
          ],
          path: 'assets/locales',
        ),
      );
    },
    blocObserver: AppBlocObserver(),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..setUp()),
      ],
      child: const _MaterialApp(),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navKey,
          themeMode: state,
          theme: ThemeResource.getTheme(themeMode: ThemeMode.light, theme: Theme.of(context)),
          darkTheme: ThemeResource.getTheme(themeMode: ThemeMode.dark, theme: Theme.of(context)),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          // initialRoute: RouteManager.mainPage,
          home: TestGamePage(),
          onGenerateRoute: (settings) => RouteManager.getRoute(settings),
        );
      },
    );
  }
}
