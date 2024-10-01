import 'package:app/Constants/strings.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static late Box _authBox;
  // init
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(AppString.authBox);
    _authBox = Hive.box(AppString.authBox);
  }

  // auth
  static Future<void> setAccessToken(String token) async {
    await _authBox.put(AppString.accessToken, token);
  }

  static String? get getAccessToken {
    return _authBox.get(AppString.accessToken);
  }

  static Future<void> setUserId(String id) async {
    await _authBox.put(AppString.userId, id);
  }

  static String? get getUserId {
    return _authBox.get(AppString.userId);
  }

  static Future<void> clearAuth() async {
    await _authBox.clear();
  }

  // app
  static Future<void> setLanguageCode(String code) async {
    await _authBox.put(AppString.languageCode, code);
  }

  static String get getLanguageCode {
    return _authBox.get(AppString.languageCode) ?? 'zh';
  }

  static Future<void> setCountryCode(String code) async {
    await _authBox.put(AppString.countryCode, code);
  }

  static String get getCountryCode {
    return _authBox.get(AppString.countryCode) ?? 'CH';
  }

  static Future<void> setFirstOpen() async {
    await _authBox.put(AppString.firstOpen, false);
  }

  static bool get getFirstOpen {
    return _authBox.get(AppString.firstOpen) ?? true;
  }
}
