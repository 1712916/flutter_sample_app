import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';

import '../image/cubit/image_list_cubit.dart';

const String appGroupId = 'group.com.vinhnt.meow';
const String iOSWidgetName = 'NewsWidget';
const String androidWidgetName = 'NewAppWidget';

abstract class AppHomeWidget {
  static Future<void> init() async {
    HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidget(HomeWidgetData data) async {
    try {
      await HomeWidget.saveWidgetData<String>('app_url', data.url);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      log('❌ Error updating widget: $e');
    }
  }

  static const String backgroundTaskName = 'home_widget_background_task';

  static void handleLaunch(BuildContext context) {
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      _launchedFromWidget(context, uri);
    });
    HomeWidget.widgetClicked.listen(
      (uri) {
        _launchedFromWidget(context, uri);
      },
    );
  }

  static void _launchedFromWidget(BuildContext context, Uri? uri) {
    if (uri != null) {
      final imageUrl = uri.queryParameters['image_url'];
      if (imageUrl != null) {
        final cubit = context.read<ImageListCubit>();
        cubit.showImageFromHomeWidget(imageUrl);
      }
    }
  }
}

class HomeWidgetData {
  final String url;
  final String? path;
  const HomeWidgetData({required this.url, this.path});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
  }

  void updateHeadline(HomeWidgetData newHeadline) async {
    print('Updating Headline: ${newHeadline.url}');
    try {
      await HomeWidget.saveWidgetData<String>('app_url', newHeadline.url);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      // ✅ Hiển thị SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Widget updated with new URL')),
        );
      }
    } catch (e) {
      print('❌ Error updating widget: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to update widget')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Stories'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          const Center(child: Text("Nhấn nút để cập nhật Widget")),
          ElevatedButton(
            onPressed: () {
              WidgetDebug.readAppGroupValue('app_url');
            },
            child: const Text("🔍 Đọc lại app_url từ App Group"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          updateHeadline(
            const HomeWidgetData(
              url: 'https://cdn2.thecatapi.com/images/21e.jpg',
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WidgetDebug {
  static const platform = MethodChannel('meow.channel/debug');

  static Future<void> readAppGroupValue(String key) async {
    try {
      final value = await platform.invokeMethod('readFromAppGroup', {"key": key});
      print('[Flutter] 🔍 App Group key [$key] = $value');
    } on PlatformException catch (e) {
      print('[Flutter] ❌ Failed to read: ${e.message}');
    }
  }
}
