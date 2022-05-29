import '../data/data.dart';

class SettingManager {
  SettingManager._();

  static Future loadSetting() async {
    //hard code here
    //todo: load setting from shared References
    isMeow = true;
    _imageTypes = ImageType.values;
    _orderType = OrderType.desc;
  }

  static Future save() async {
    //todo: save to shared references
  }

  static bool isMeow = true;

  static void switchMeowOrDog() {
    isMeow = !isMeow;
  }

  static List<ImageType>? _imageTypes;

  static List<ImageType> get imageTypes => _imageTypes ?? ImageType.values;

  static set imageTypes(List<ImageType> imageTypes) => _imageTypes = imageTypes;

  static OrderType? _orderType;

  static OrderType get orderType => _orderType ?? OrderType.desc;

  static set orderType(OrderType orderType) => _orderType = orderType;
}
