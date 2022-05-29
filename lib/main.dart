import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/cubits/cubits.dart';
import 'package:flutter_sample_app/routers/route.dart';

import 'dependencies/app_dependencies.dart';
import 'helpers/helpers.dart';
import 'resources/theme/theme_data.dart';
import 'utils/utils.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SettingManager.loadSetting();
  BlocOverrides.runZoned(
    () async {
      await AppDependencies.init();
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
      print('${bloc.runtimeType} $change');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = InternetCheckerHelper.connectivity.onConnectivityChanged.listen(InternetCheckerHelper.changeConnectivityResult);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

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
          initialRoute: RouteManager.mainPage,
          onGenerateRoute: (settings) => RouteManager.getRoute(settings),
        );
      },
    );
  }
}
