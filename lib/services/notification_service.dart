import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _requestedPermissions = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (response) {
      // handle notification tapped
      if (kDebugMode) {
        debugPrint('Notification tapped: ${response.payload}');
      }
    });

    // Create default channel for Android
    const channel = AndroidNotificationChannel(
      'pomodorx_channel',
      'PomodoRx Notifications',
      description: 'Notifications for timer events',
      importance: Importance.high,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _requestPermissionsIfNeeded();

    _initialized = true;
  }

  Future<void> showNotification({required int id, required String title, required String body, String? payload}) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodorx_channel',
      'PomodoRx Notifications',
      channelDescription: 'Notifications for timer events',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    final iosDetails = DarwinNotificationDetails(presentSound: true);

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> ensurePermissionsRequested() async {
    await _requestPermissionsIfNeeded(force: true);
  }

  Future<void> _requestPermissionsIfNeeded({bool force = false}) async {
    if (_requestedPermissions && !force) return;

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isRestricted || status.isLimited) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _requestedPermissions = true;
  }
}
