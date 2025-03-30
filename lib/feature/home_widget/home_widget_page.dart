import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.vinhnt.widgets';
const String iOSWidgetName = 'NewsWidget';
const String androidWidgetName = 'NewsWidget';

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
