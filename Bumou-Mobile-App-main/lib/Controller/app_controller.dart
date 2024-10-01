import 'package:app/Controller/auth_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  int selectedLanguage = LocalStorage.getLanguageCode == 'en' ? 0 : 1;
  final Rx<Locale> currentLocale = Rx<Locale>(Get.locale!);

  final List locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': '中文', 'locale': const Locale('zh', 'CH')},
  ];

  updateLanguage(Locale locale) async {
    currentLocale.value = locale;
    await LocalStorage.setLanguageCode(locale.languageCode);
    await LocalStorage.setCountryCode(locale.countryCode!);
    await Get.updateLocale(locale);
    if (Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().user != null) {
      await Get.find<AuthController>().updateUser(Get.context!,
          data: {'local': '${locale.languageCode}_${locale.countryCode}'});
    }
    update();
  }
}
