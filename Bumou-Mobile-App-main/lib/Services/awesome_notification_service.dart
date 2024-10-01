// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'notification_service.dart';
//
// class AwesomeNotificationService implements NotificationService {
//
//   AwesomeNotificationService(){
//
//   }
//   @override
//   Future<void> showNotification(String title, String body, List<String> iconPaths, List<String> buttonLabels) async {
//     // Ensure at least 5 icons and labels provided
//     if (iconPaths.length < 5 || buttonLabels.length < 5) {
//       throw Exception("Please provide 5 icons and labels for buttons");
//     }
//
//     final List<NotificationActionButton> actionButtons = [];
//     for (int i = 0; i < 5; i++) {
//       actionButtons.add(
//         NotificationActionButton(
//           key: 'action_$i',
//           icon: iconPaths[i],
//           label: buttonLabels[i],
//         ),
//       );
//     }
//
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 00,
//         channelKey: 'persistent_channel',
//         title: title,
//         body: body,
//         locked: true,
//         wakeUpScreen: true,
//         notificationLayout: NotificationLayout.BigText, // Large notification layout
//       ),
//       actionButtons:actionButtons,
//     );
//
//   }
//
//
//   @override
//   Future<void> initialize() async {
//
//     await AwesomeNotifications().requestPermissionToSendNotifications();
//
//     await AwesomeNotifications().initialize(
//       // Your notification channel configuration
//       null,[
//       NotificationChannel(
//         channelKey: 'persistent_channel',
//         channelName: 'Persistent Notifications',
//         channelDescription: 'Notifications that persist even when app is closed',
//         importance: NotificationImportance.High,
//         criticalAlerts: true, // Makes notification persistent on some devices
//       )
//     ],
//     );
//   }
// }
