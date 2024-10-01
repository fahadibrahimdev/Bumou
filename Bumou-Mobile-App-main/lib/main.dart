import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:app/Constants/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Constants/language.dart';
import 'Constants/theme.dart';
import 'Data/Local/hive_storage.dart';
import 'Model/ip_data.dart';
import 'View/Splash/splash.dart';
import 'firebase_options.dart';

IPData? ipData;

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kReleaseMode) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await LocalStorage.init();
  await initializeDateFormatting("zh_CH", "").then((_) {
    DateTime now = DateTime.now();
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'en_US').format(now));
    debugPrint(DateFormat('EEEE, MMMM, dd, yyyy, h:mm a', 'zh_CH').format(now));
  });

  await clearAliyunPushInitialization();
  
  // Initialize Aliyun Push
  await initAliyunPush();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String languageCode = LocalStorage.getLanguageCode;
    String countryCode = LocalStorage.getCountryCode;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: LocaleString(),
        locale: Locale(languageCode, countryCode),
        fallbackLocale: const Locale('en', 'US'),
        title: "咘呣 Bumou",
        theme: AppTheme.lightTheme(context),
        home: const SplashView(),
      ),
    );
  }
}

Future<void> initAliyunPush() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if Aliyun Push has already been initialized
  bool isInitialized = prefs.getBool('aliyunPushInitialized') ?? false;

  if (isInitialized) {
    developer.log('Aliyun Push is already initialized. Skipping initialization.');
    return;
  }

  try {
    final AliyunPush aliyunPush = AliyunPush();

    // Fetch the device token
    aliyunPush.getDeviceId().then((token) {
      developer.log('Device token: $token');
    });

    // Create Android channel (if necessary)
    if (Platform.isAndroid) {
      await aliyunPush.createAndroidChannel(
        '8.0up', 'TestChannel', 3, 'Test notification channel',
      );
    }

    // Initialize Aliyun Push with your app key and app secret
    String appKey = Apis.aliyueApiKey;
    String appSecret = Apis.aliyueAppSecret;

    await aliyunPush.initPush(appKey: appKey, appSecret: appSecret).then((value) async {
      var code = value['code'];
      if (code == kAliyunPushSuccessCode) {
        developer.log('Initialized Aliyun Push successfully');
        aliyunPush.getDeviceId().then((token) {
          developer.log('Device token: $token');
        });

        // Store the initialization state in SharedPreferences
        await prefs.setBool('aliyunPushInitialized', true);
      } else {
        String errorMsg = value['errorMsg'];
        developer.log('Aliyun Push initialization failed: $errorMsg');
      }
    });

    // Set message receiver
    aliyunPush.addMessageReceiver(
      onNotification: onNotification,
      onMessage: onMessage,
      onNotificationOpened: onNotificationOpened,
      onNotificationRemoved: onNotificationRemoved,
      onIOSChannelOpened: onIOSChannelOpened,
      onIOSRegisterDeviceTokenSuccess: onIOSRegisterDeviceTokenSuccess,
      onIOSRegisterDeviceTokenFailed: onIOSRegisterDeviceTokenFailed,
    );
  } catch (e) {
    developer.log('Aliyun Push initialization error: $e');
  }
}

Future<void> clearAliyunPushInitialization() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('aliyunPushInitialized', false);
  developer.log('Aliyun Push initialization status cleared.');
}

// Aliyun Push Callbacks
Future<void> onNotification(Map<dynamic, dynamic> message) async {
  try {
    developer.log("Notification Received: $message");
    await showLocalNotification(message);
  } catch (e) {
    developer.log("Error in onNotification: $e");
  }
}

Future<void> onMessage(Map<dynamic, dynamic> message) async {
  try {
    developer.log("Message Received: $message");
  } catch (e) {
    developer.log("Error in onMessage: $e");
  }
}

Future<void> onNotificationOpened(Map<dynamic, dynamic> message) async {
  try {
    developer.log("Notification Opened: $message");
  } catch (e) {
    developer.log("Error in onNotificationOpened: $e");
  }
}

Future<void> onNotificationRemoved(Map<dynamic, dynamic> message) async {
  try {
    developer.log("Notification Removed: $message");
  } catch (e) {
    developer.log("Error in onNotificationRemoved: $e");
  }
}

Future<void> onIOSChannelOpened(Map<dynamic, dynamic> message) async {
  try {
    developer.log("iOS Channel Opened: $message");
  } catch (e) {
    developer.log("Error in onIOSChannelOpened: $e");
  }
}

Future<void> onIOSRegisterDeviceTokenSuccess(Map<dynamic, dynamic> message) async {
  try {
    developer.log("iOS Device Token Registration Success: $message");
  } catch (e) {
    developer.log("Error in onIOSRegisterDeviceTokenSuccess: $e");
  }
}

Future<void> onIOSRegisterDeviceTokenFailed(Map<dynamic, dynamic> message) async {
  try {
    developer.log("iOS Device Token Registration Failed: $message");
  } catch (e) {
    developer.log("Error in onIOSRegisterDeviceTokenFailed: $e");
  }
}

// Local Notification Handler
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> showLocalNotification(Map<dynamic, dynamic> message) async {
  try {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    );

    // Initialize notifications plugin once
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: (response) async {
        developer.log('Local notification response: $response');
      },
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_id_4",
        message['title'] ?? 'No Title',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      (await flutterLocalNotificationsPlugin.getActiveNotifications()).length,
      message['title'],
      message['content'],
      platformChannelSpecifics,
      payload: jsonEncode(message),
    );
  } catch (e) {
    developer.log("Error showing local notification: $e");
  }
}

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) async {
  try {
    developer.log("Handling a background notification response: ${response.actionId}");
  } catch (e) {
    developer.log("Error handling background notification: $e");
  }
}
