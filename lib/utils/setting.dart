import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/data.dart';

class _SettingModel {
  final bool? isMeow;
  final List<ImageType>? imageTypes;
  final OrderType? orderType;
  final int? patternIndex;

  factory _SettingModel.fromJson(Map<String, dynamic> json) {
    return _SettingModel(
      isMeow: json['isMeow'],
      imageTypes: json['imageTypes'].map<ImageType>((e) => e.toString().toImageType()!).toList(),
      orderType: json['orderType'].toString().toOrderType(),
      patternIndex: json['patternIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMeow': isMeow,
      'imageTypes': imageTypes?.map((e) => e.toString()).toList(),
      'orderType': orderType.toString(),
      'patternIndex': patternIndex,
    };
  }

  _SettingModel({
    this.isMeow,
    this.imageTypes,
    this.orderType,
    this.patternIndex,
  });
}

class SettingManager {
  SettingManager._();

  static const String SETTING_KEY = 'setting_data';

  static Future loadSetting() async {
    log('loading setting');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? settingData = prefs.getString(SETTING_KEY);
    log('loading setting: $settingData');
    if (settingData != null) {
      final _SettingModel _settingModel = _SettingModel.fromJson(jsonDecode(settingData));
      isMeow = _settingModel.isMeow ?? true;
      _imageTypes = _settingModel.imageTypes ?? ImageType.values;
      _orderType = _settingModel.orderType ?? OrderType.desc;
      patternIndex = _settingModel.patternIndex ?? 0;
    } else {
      //set default settings
      isMeow = true;
      _imageTypes = ImageType.values;
      _orderType = OrderType.desc;
      patternIndex = 0;
      save();
    }
  }

  static Future save() async {
    log('save setting');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> settingData = _SettingModel(
      isMeow: isMeow,
      imageTypes: imageTypes,
      orderType: orderType,
      patternIndex: patternIndex,
    ).toJson();
    log('save setting: $settingData');
    await prefs.setString(SETTING_KEY, jsonEncode(settingData));
  }

  static bool isMeow = true;

  static void switchMeowOrDog() {
    isMeow = !isMeow;
  }

  static int? patternIndex;

  static List<ImageType>? _imageTypes;

  static List<ImageType> get imageTypes => _imageTypes ?? ImageType.values;

  static set imageTypes(List<ImageType> imageTypes) => _imageTypes = imageTypes;

  static OrderType? _orderType;

  static OrderType get orderType => _orderType ?? OrderType.desc;

  static set orderType(OrderType orderType) => _orderType = orderType;

  static String _downloadPath = '/storage/emulated/0/meow_app';

  static String get downloadPath => _downloadPath;

  static set downloadPath(String downloadPath) => _downloadPath = downloadPath;
}
