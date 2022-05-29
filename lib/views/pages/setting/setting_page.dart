import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../../../data/data.dart';
import '../../../resources/resources.dart';
import '../../../routers/route.dart';
import '../../../widgets/widgets.dart';
import '../base_page/base_page.dart';

const String iconFoot =
    'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAABmJLR0QA/wD/AP+gvaeTAAACr0lEQVRoge2YzW8OURTGf6oSkjf6hpX6KAsrYsWiCdWEWIggEhFf/wRCUiyJEnvWllYoS5YSLUkjIZXWR3ykEUQTlKZJLe7cZsi9d869Z2YWzJOczdv7O+9z+s7c+8xAo0aN/kstAc4DY8BP4CVwGegSsG3gCvAqY8eAc8DiSpw6tBx4Asw5agLoCbBrMcO62MfAsspc5zTkMWBrGOh0cIsykyH2TsXe6S8wYOuogz0uZPtiDHVEDnBEuO5wyWxpKroEbE062I9CdjjGUOwv0Bauc92MGtar2AG+Ctd9KZn1KnaAEcU6DVuatiO7jl034jEhu7XKAcDs1SEDj3CfA52YGzTE3qrYO2BO4hGPgXFgTYDtwZzWvt2nlpMYTG45CzwHpjNTl4ClArYLGMyY6azHACVmIU1QK0vJgU8T1PLqB+4D37J6AOwQsqrAlxrU8roY4K8WsKrApwlqVicE/ECAVwW+60L4rufL12NuyiL+F7DB0+Oe0MM1F6wJagA3hPwccNPTQxX4fPvz3zXjYFdkn0sHmAVWO/pIe0xYIJ+FNGFrH+YGlGohcMDxebSH/ACasLVLyOa1U9hb6kEc1FxPVq+FbL7eOvpIA98232QpQa0Ds7PEDjCDuZTyUge+lKC2JcG8rV5HP3Xgiwlq3cBTxQDPcO9GlQc+gI3AG4V5W++ATWUak2gzZsvTmrc1hbkUa1EL818ry3z+l2jVMcCpCszbOhlrJvatBMDuBEaqPbFAygDrEhipQs/TTqUMsCCBqax3ygAvEhipxmOBlAGGEhipblfYe15tzENN2TvQJPIXwGrtxTyUFJn6nlXRullgf13mrQ4SPo3fY8JaL/AhsG4KOFSz93mtBC4Ao8AP4BPwEDjNn6dqCziT/e0zJqCNYl7BrKrRb6NG/5x+AxOtVYYHNpIiAAAAAElFTkSuQmCC';
var imageBytes = const Base64Decoder().convert(iconFoot);

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key, required this.cubit}) : super(key: key);
  final SettingsCubit cubit;

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends CustomState<SettingPage, SettingsCubit> {
  @override
  Widget buildContent(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (cubit.state.isChange ?? false) {
          await showConfirmDialog(
            context,
            onYes: () => onSave(),
            onNo: () => Navigator.of(context).pop(),
          );
        }
        return true;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleContent(
              title: LocaleKeys.catOrDog.tr(),
              content: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: BlocBuilder<SettingsCubit, SettingState>(
                      buildWhen: (previous, current) => false,
                      builder: (context, state) {
                        return CustomSwitch(
                          isMeow: state.isMeow!,
                          onChange: (isMeow) {
                            cubit.onChangeMeow(isMeow);
                          },
                        );
                      }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.orderSearch,
              style: Theme.of(context).textTheme.headline6,
            ).tr(),
            const SizedBox(height: 8),
            BlocBuilder<SettingsCubit, SettingState>(
                buildWhen: (previous, current) => false,
                builder: (context, state) {
                  return SingleSelectionWidget<OrderType>(
                    data: OrderType.values,
                    defaultIndex: state.orderType!.index,
                    buildItemNotSelect: (item) {
                      return MultiSelectionItem(
                        title: item.name,
                        isSelected: false,
                      );
                    },
                    buildItemSelected: (item) {
                      return MultiSelectionItem(
                        title: item.name,
                        isSelected: true,
                      );
                    },
                    onChoice: (index) => cubit.onChangeOrderType(OrderType.values[index]),
                  );
                }),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.imageType,
              style: Theme.of(context).textTheme.headline6,
            ).tr(),
            const SizedBox(height: 8),
            BlocBuilder<SettingsCubit, SettingState>(
              buildWhen: (previous, current) => false,
              builder: (context, state) {
                return MultiSelectionWidget<ImageType>(
                  list: ImageType.values,
                  currentSelects: state.imageTypes!.map((e) => e.index).toSet(),
                  onListChange: (imageTypes) => cubit.onChangeImageTypes(imageTypes),
                  itemBuilder: (item) {
                    return MultiSelectionItem(
                      title: item.name,
                      isSelected: false,
                    );
                  },
                  selectedBuilder: (item) {
                    return MultiSelectionItem(
                      title: item.name,
                      isSelected: true,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        LocaleKeys.settings,
        style: TextStyle(color: Colors.black),
      ).tr(),
      backgroundColor: Theme.of(context).primaryColor,
      leading: BackButton(
        color: Colors.black,
        onPressed: () async {
          if (cubit.state.isChange ?? false) {
            await showConfirmDialog(
              context,
              onYes: () => onSave(),
              onNo: () => Navigator.of(context).pop(),
            );
          }
          Navigator.of(context).pop();
        },
      ),
      actions: [
        BlocBuilder<SettingsCubit, SettingState>(
          buildWhen: (previous, current) => previous.isChange != current.isChange,
          builder: ((context, state) {
            return IconButton(
              onPressed: state.isChange! ? () => onSave() : null,
              icon: Icon(
                Icons.save,
                color: state.isChange! ? Colors.black : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Future onSave() async {
    await LoadingDialog.doSomething(
      context,
      call: () async {
        return await cubit.onSave();
      },
      onDone: (isSaved) async {
        if (isSaved is bool && isSaved) {
          Toast.makeText(message: LocaleKeys.savedSettings.tr());
          await Future.delayed(const Duration(milliseconds: 300));
          Navigator.of(context).pushNamedAndRemoveUntil(RouteManager.home, (route) => false);
        } else {
          Toast.makeText(message: LocaleKeys.savedSettingsFailure.tr());
        }
      },
    );
  }

  @override
  SettingsCubit get cubit => widget.cubit;
}
