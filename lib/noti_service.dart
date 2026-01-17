// noti_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService with WidgetsBindingObserver {
  NotificationService._internal() {
    WidgetsBinding.instance.addObserver(this);

    // 👈 تحديد الحالة من أول لحظة
    _isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _isForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
  }

  Future<void> initNotification() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  Future<void> show({
    required String title,
    required String body,
  }) async {
    if (_isForeground) {
      // 👇 فقط Overlay لما التطبيق مفتوح
      showSimpleNotification(
        Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(body, style: const TextStyle(color: Colors.white70)),
        leading: const Icon(Icons.notifications_active, color: Colors.white),
        background: Colors.blueGrey,
        duration: const Duration(seconds: 3),
      );
    } else {
      // 👇 فقط إشعار نظام لما التطبيق بالخلفية أو مسكّر
      _showSystemNotification(title, body);
    }
  }

  Future<void> _showSystemNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      title,
      body,
      details,
    );
  }
}
