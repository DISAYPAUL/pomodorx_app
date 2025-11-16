import 'package:flutter/material.dart';

import 'app.dart';
import 'services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  runApp(PomodoRxApp(hiveService: hiveService));
}
