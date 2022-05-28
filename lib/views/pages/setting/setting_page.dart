import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sample_app/data/data.dart';

const String iconFoot =
    'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAABmJLR0QA/wD/AP+gvaeTAAACr0lEQVRoge2YzW8OURTGf6oSkjf6hpX6KAsrYsWiCdWEWIggEhFf/wRCUiyJEnvWllYoS5YSLUkjIZXWR3ykEUQTlKZJLe7cZsi9d869Z2YWzJOczdv7O+9z+s7c+8xAo0aN/kstAc4DY8BP4CVwGegSsG3gCvAqY8eAc8DiSpw6tBx4Asw5agLoCbBrMcO62MfAsspc5zTkMWBrGOh0cIsykyH2TsXe6S8wYOuogz0uZPtiDHVEDnBEuO5wyWxpKroEbE062I9CdjjGUOwv0Bauc92MGtar2AG+Ctd9KZn1KnaAEcU6DVuatiO7jl034jEhu7XKAcDs1SEDj3CfA52YGzTE3qrYO2BO4hGPgXFgTYDtwZzWvt2nlpMYTG45CzwHpjNTl4ClArYLGMyY6azHACVmIU1QK0vJgU8T1PLqB+4D37J6AOwQsqrAlxrU8roY4K8WsKrApwlqVicE/ECAVwW+60L4rufL12NuyiL+F7DB0+Oe0MM1F6wJagA3hPwccNPTQxX4fPvz3zXjYFdkn0sHmAVWO/pIe0xYIJ+FNGFrH+YGlGohcMDxebSH/ACasLVLyOa1U9hb6kEc1FxPVq+FbL7eOvpIA98232QpQa0Ds7PEDjCDuZTyUge+lKC2JcG8rV5HP3Xgiwlq3cBTxQDPcO9GlQc+gI3AG4V5W++ATWUak2gzZsvTmrc1hbkUa1EL818ry3z+l2jVMcCpCszbOhlrJvatBMDuBEaqPbFAygDrEhipQs/TTqUMsCCBqax3ygAvEhipxmOBlAGGEhipblfYe15tzENN2TvQJPIXwGrtxTyUFJn6nlXRullgf13mrQ4SPo3fY8JaL/AhsG4KOFSz93mtBC4Ao8AP4BPwEDjNn6dqCziT/e0zJqCNYl7BrKrRb6NG/5x+AxOtVYYHNpIiAAAAAElFTkSuQmCC';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleContent(
                title: 'Meow or Gauw',
                content: Align(
                  alignment: Alignment.center,
                  child: SizedBox(width: MediaQuery.of(context).size.width * 0.5, child: CustomSwitch()),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oder Search',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              ...OrderType.values
                  .map(
                    (order) => CheckboxListTile(
                      contentPadding: const EdgeInsets.all(0),
                      selected: true,
                      value: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) {},
                      title: Text(
                        order.name,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 16),
              Text(
                'Image Type',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              ...OrderType.values
                  .map(
                    (order) => CheckboxListTile(
                      contentPadding: const EdgeInsets.all(0),
                      selected: true,
                      value: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) {},
                      title: Text(
                        order.name,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

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

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({Key? key}) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool isMeow = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Meow'),
        Expanded(
          child: GestureDetector(
            onTap: () {
              isMeow = !isMeow;
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFd6edfa),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 200),
                alignment: isMeow ? Alignment.centerLeft : Alignment.centerRight,
                curve: Curves.fastOutSlowIn,
                child: Image.memory(
                  Base64Decoder().convert(iconFoot),
                ),
              ),
            ),
          ),
        ),
        Text('Gauw'),
      ],
    );
  }
}
