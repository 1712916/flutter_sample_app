import 'package:flutter/material.dart';

class TitleContent extends StatelessWidget {
  const TitleContent({Key? key, required this.title, required this.content}) : super(key: key);
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline6,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}
