import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../widgets/widgets.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String? version;

  @override
  void initState() {
    PackageInfo.fromPlatform().then((value) {
      version = value.version;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Info',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleContent(
            title: 'Info',
            content: Text(version ?? ''),
          ),
          const SizedBox(height: 8),
          TitleContent(
            title: 'Mô tả',
            content: Text('TÔi sẽ ghi mô tả ở đây'),
          ),
          const SizedBox(height: 8),
          TitleContent(
            title: 'Liên hệ',
            content: Text('smile.vinhnt@gmail.com'),
          ),
        ],
      ),
    );
  }
}
