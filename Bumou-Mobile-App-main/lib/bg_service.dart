// this will be used as notification channel id
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

@pragma('vm:entry-point')
Future<void> _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse message) async {
  print("BG TAATTTT " + " --- " * 20);
}

class NotificationsService {
  show() async {
    tz.initializeTimeZones();

    // WidgetsFlutterBinding.ensureInitialized();

    print("trying to show notification" * 20);

    final FlutterLocalNotificationsPlugin localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    bool? initialised = await localNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: (message) async {},
    );

    print("INITALISED --> ${initialised}");

    await localNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'full screen channel id',
          'full screen channel name',
          channelDescription: 'full screen channel description',
          priority: Priority.high,
          importance: Importance.high,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("show notification");
  }
}
