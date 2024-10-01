// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'notification_service.dart';
//
// class LocalNotificationService extends NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//
//   void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
//     final String? payload = notificationResponse.payload;
//     if (notificationResponse.payload != null) {
//       debugPrint('notification payload: $payload');
//     }
//   }
//
//   @override
//   Future<void> initialize() async {
//
//     /// Requesting permissions on Android 13 or higher
//     flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//
//     /// Requesting permissions on iOS
//      await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(android: initializationSettingsAndroid);
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//     );
//
//     showDailyMoodNotification();
//
//   }
//
//   Future<void> onSelectNotification(String? payload) async {
//     // Handle notification tap
//     if (payload != null) {
//       // Navigate to the appropriate screen or perform any action
//     }
//   }
//
//   @override
//   Future<void> showDailyMoodNotification() async {
//     debugPrint("++++++ showing notification...");
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       'mood_channel',
//       'Daily Mood',
//       channelDescription: 'Show daily mood options',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       ongoing: true, // Make the notification persistent
//
//       styleInformation: BigTextStyleInformation(''),
//       visibility: NotificationVisibility.public,
//       actions: [
//         AndroidNotificationAction('action_1', '', showsUserInterface: true,
//           icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//         ),
//         // AndroidNotificationAction('action_2', 'BADDBADDBADDBADD', showsUserInterface: true),
//         // AndroidNotificationAction('action_3', 'NEUTRAL', showsUserInterface: true),
//         // AndroidNotificationAction('action_4', 'GOOD', showsUserInterface: true),
//         // AndroidNotificationAction('action_5', 'VERY GOOD', showsUserInterface: true),
//
//       ],
//     );
//
//     const NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'How are you feeling today?',
//       'Select your mood: 😊 😃 😐 😢 😞',
//       platformChannelSpecifics,
//       payload: 'mood_payload',
//     );
//   }
//
//   @override
//   void scheduleDailyNotification() {
//     // TODO: implement scheduleDailyNotification
//   }
//
//
//
// }
//
