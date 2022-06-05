
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cubits.dart';
import '../resources/resources.dart';
import '../views/pages/pages.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({Key? key,required this.isMeow, this.onChange}) : super(key: key);
  final bool isMeow;
  final Function(bool)? onChange;

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool isMeow;

  @override
  void initState() {
    isMeow = widget.isMeow;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          LocaleKeys.meowTitle,
          style: textTheme.headline6!.copyWith(
            color: isMeow ? Colors.black : Colors.grey,
          ),
        ).tr(),
        Expanded(
          child: GestureDetector(
            onTap: () {
              isMeow = !isMeow;
              widget.onChange?.call(isMeow);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.read<ThemeCubit>().getColors.focusColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: isMeow ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Image.memory(imageBytes),
                ),
              ),
            ),
          ),
        ),
        Text(
          LocaleKeys.dogTitle,
          style: textTheme.headline6!.copyWith(
            color: !isMeow ? Colors.black : Colors.grey,
          ),
        ).tr(),
      ],
    );
  }
}
