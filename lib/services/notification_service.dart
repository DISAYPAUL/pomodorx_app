import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const _channelId = 'pomodorx_alerts_v2';
  static const _channelName = 'PomodoRx Alerts';
  static const _channelDescription = 'Notifications for timer events';

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

    await _ensureAndroidChannel();

    await _requestPermissionsIfNeeded();

    _initialized = true;
    if (kDebugMode) debugPrint('✅ NotificationService initialized successfully');
  }

  Future<void> showNotification({required int id, required String title, required String body, String? payload}) async {
    // Ensure initialized and permissions requested so showNotification doesn't fail silently.
    try {
      if (!_initialized) {
        await init();
      }
      await _requestPermissionsIfNeeded();
    } catch (e, s) {
      if (kDebugMode) debugPrint('Notification init failed: $e\n$s');
    }
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // Using default system notification sound (no custom sound file required)
      ticker: 'ticker',
      // Use the launcher-based drawable for both small and large icon so Android can resolve resources.
      icon: 'ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('ic_notification'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (kDebugMode) {
      debugPrint('🔔 Attempting to show notification:');
      debugPrint('  ID: $id');
      debugPrint('  Title: $title');
      debugPrint('  Body: $body');
      debugPrint('  Channel: $_channelId');
    }

    try {
      await _plugin.show(id, title, body, details, payload: payload);
      if (kDebugMode) debugPrint('✅ Notification shown successfully');
    } catch (e, s) {
      if (kDebugMode) debugPrint('❌ Error showing notification: $e\n$s');
    }
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
      // Ensure we're on the latest known status.
      final finalStatus = await Permission.notification.status;
      if (kDebugMode) debugPrint('Notification permission status: $finalStatus');
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

  /// Returns whether notifications are allowed for this app at platform level.
  Future<bool> areNotificationsAllowed() async {
    if (Platform.isAndroid) {
      return await _areAndroidNotificationsEnabled();
    }
    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted || status.isLimited || status.isRestricted;
    }
    // On other platforms assume allowed (desktop/web behaviour varies)
    return true;
  }

  Future<bool> _areAndroidNotificationsEnabled() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    final enabled = await androidPlugin.areNotificationsEnabled();
    return enabled ?? true;
  }

  Future<void> _ensureAndroidChannel() async {
    if (!Platform.isAndroid) return;
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Clean up the legacy channel so new importance/sound settings apply.
    try {
      await androidPlugin.deleteNotificationChannel('pomodorx_channel');
    } catch (_) {
      // Ignore if the old channel didn't exist.
    }

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      // Using default system notification sound
      enableVibration: true,
      showBadge: true,
    );

    if (kDebugMode) debugPrint('📢 Creating Android notification channel: $_channelId');
    await androidPlugin.createNotificationChannel(channel);
    if (kDebugMode) debugPrint('✅ Android notification channel created successfully');
  }

  /// Open the OS-level notification settings for the app (Android/iOS).
  Future<void> openNotificationSettings() async {
    // plugin methods are limited across versions; use permission_handler to
    // open the app-level settings which include notification controls.
    await openAppSettings();
  }

  /// Attempt to open the notification channel settings for the app. If the
  /// plugin doesn't expose a direct channel settings API for this platform,
  /// fall back to opening the app-level settings via `openAppSettings`.
  Future<void> openNotificationChannelSettings() async {
    await openAppSettings();
  }
}
