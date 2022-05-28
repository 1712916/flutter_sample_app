import '../data/data.dart';

class SettingManager {
  SettingManager._();

  static List<ImageType>? _imageTypes;

  static List<ImageType> get imageTypes => _imageTypes ?? ImageType.values;

  static set imageTypes(List<ImageType> imageTypes) => _imageTypes = imageTypes;

  static OrderType? _orderType;

  static OrderType get orderType => _orderType ?? OrderType.desc;

  static set orderType(OrderType orderType) => _orderType = orderType;
}
