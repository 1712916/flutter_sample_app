import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../resources/resources.dart';
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: TitleContent(
                title: LocaleKeys.version.tr(),
                content: Text(version ?? ''),
              ),
            ),
            const SizedBox(height: 8),
            CustomCard(
              child: TitleContent(
                title: LocaleKeys.description.tr(),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.descriptionDetail.tr()),
                    const SizedBox(height: 4),
                    Text('https://thecatapi.com', style: textTheme.subtitle1),
                    const SizedBox(height: 4),
                    Text('https://thedogapi.com', style: textTheme.subtitle1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            CustomCard(
              child: TitleContent(
                title: LocaleKeys.function.tr(),
                content: getListString(LocaleKeys.functionDetail.tr()),
              ),
            ),
            const SizedBox(height: 8),
            CustomCard(
              child: TitleContent(
                title: LocaleKeys.contact.tr(),
                content: Text('smile.vinhnt@gmail.com'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget getListString(String value) {
  final List<String> strings = value.split('_');
  List<Widget> widgets = [];

  List.generate(strings.length, (index) {
    widgets.add(Text(strings[index]));

    if (index != strings.length - 1) {
      widgets.add(const SizedBox(height: 4));
    }
  });

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
}

class CustomCard extends StatelessWidget {
  const CustomCard({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(offset: Offset(2, 4), color: Colors.grey.shade300),
        ],
      ),
      child: child,
    );
  }
}
