import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  NotificationServices();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  
  static void initialize() async {
    const androidInitializeSettings = AndroidInitializationSettings('logo');
    await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: androidInitializeSettings,
    ), onDidReceiveNotificationResponse: (response) {
      print(response.payload);
    });
  }
  static AndroidNotificationDetails androidChannel =
      const AndroidNotificationDetails(
      'zenipay', 'zenipay instant notifications',
      importance: Importance.high,
      priority: Priority.high
  );
  static Future showInstantNotification({
    required int id,
    required String title,
    required String body
  }) async {
    final notification = NotificationDetails(android: androidChannel);
    flutterLocalNotificationsPlugin.show(id, title, body, notification);
  }
  static Future showScheduledNotification({
    required int id,
    required String title,
    required String body
  }) async {
    final notification = NotificationDetails(android: androidChannel);
    flutterLocalNotificationsPlugin.periodicallyShow(
      id, title, body, RepeatInterval.everyMinute ,notification
    );
  }
  static Future stopScheduledNotification({
    required int id,
    required String title,
    required String body
  }) async {
    final notification = NotificationDetails(android: androidChannel);
    flutterLocalNotificationsPlugin.cancel(
      id
    );
  }
}