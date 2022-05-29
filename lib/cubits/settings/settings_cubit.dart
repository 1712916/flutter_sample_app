import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/data/data.dart';
import 'package:flutter_sample_app/utils/setting.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingState> {
  SettingsCubit()
      : super(SettingState(
          imageTypes: SettingManager.imageTypes,
          orderType: SettingManager.orderType,
          isMeow: SettingManager.isMeow,
          isChange: false,
        ));

  bool get isChangeSettings => _checkChangeSettings();

  bool _checkChangeSettings() {
    int getTotalIndexOfImageTypes(List<ImageType> imageType) {
      return imageType.fold<int>(0, (previousValue, element) {
        return previousValue + (element.index + 1);
      });
    }
    if (SettingManager.isMeow != state.isMeow) {
      return true;
    } else if (SettingManager.orderType != state.orderType) {
      return true;
    } else if (getTotalIndexOfImageTypes(SettingManager.imageTypes) != getTotalIndexOfImageTypes(state.imageTypes!)) {
      return true;
    }
    return false;
  }

  Future<bool> onSave() async {
    SettingManager.isMeow = state.isMeow!;
    SettingManager.orderType = state.orderType!;
    SettingManager.imageTypes = state.imageTypes!;
    SettingManager.save();
    return true;
  }

  void onChangeMeow(bool isMeow) {
    emit(state.copyWith(isMeow: isMeow));
    emit(state.copyWith(isChange: isChangeSettings));
  }

  void onChangeOrderType(OrderType orderType) {
    emit(state.copyWith(orderType: orderType));
    emit(state.copyWith(isChange: isChangeSettings));
  }

  void onChangeImageTypes(Set<int> imageTypes) {
    emit(state.copyWith(imageTypes: imageTypes.map((index) => ImageType.values[index]).toList()));
    emit(state.copyWith(isChange: isChangeSettings));
  }
}
