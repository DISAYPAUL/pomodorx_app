import 'package:flutter/material.dart';

import 'app.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  // Initialize local notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.ensurePermissionsRequested();
  runApp(PomodoRxApp(hiveService: hiveService));
}
