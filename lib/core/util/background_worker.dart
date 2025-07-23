import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/data_provider/remote/search_service.dart';
import '../../data/response/status_code.dart';
import '../../feature/home_widget/home_widget_page.dart';
import '../index.dart';

abstract class BackgroundWorker {
  static Future<void> init() {
    return Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> registerLoadHomeWidgetData() {
    return Workmanager().registerPeriodicTask(
      AppHomeWidget.backgroundTaskName,
      AppHomeWidget.backgroundTaskName,
      tag: AppHomeWidget.backgroundTaskName,
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: const Duration(hours: 2),
    );
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) async {
      switch (task) {
        case AppHomeWidget.backgroundTaskName:

          ///call api get images
          final rs = await searchIsolate(
            SearchQueryModel(
              url: ApiPath.searchAndPagination.getPath(),
              limit: 1,
              page: 1,
              apiKey: '',
            ),
          );

          try {
            ///update home widget
            rs.statusCode == StatusCode.success
                ? await AppHomeWidget.updateWidget(HomeWidgetData(url: rs.data!.first.url!))
                : log('❌ Error updating widget: ${rs.message}');
          } catch (e) {
            log('❌ Error updating widget: $e');
          }

          return Future.value(true);
        default:
          return Future.error('No task found for $task');
      }
    },
  );
}
