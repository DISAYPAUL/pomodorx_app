import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'constants/design_tokens.dart';
import 'providers/auth_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/reviewer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/topic_provider.dart';
import 'routes.dart';
import 'services/hive_service.dart';
import 'services/seed_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';

class PomodoRxApp extends StatelessWidget {
  const PomodoRxApp({super.key, required this.hiveService});

  final HiveService hiveService;

  @override
  Widget build(BuildContext context) {
    final storage = StorageService(hiveService);
    final seedService = SeedService(storage);

    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: hiveService),
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => TopicProvider(storage, seedService)),
        ChangeNotifierProvider(create: (_) => QuizProvider(storage)),
        ChangeNotifierProvider(create: (_) => ReviewerProvider(storage, TtsService())),
        ChangeNotifierProvider(create: (_) => ProgressProvider()..loadProgress()),
        ChangeNotifierProvider(
          create: (context) => PomodoroProvider(context.read<ProgressProvider>())..loadSettings(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            themeMode: settings.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final colors = DesignTokens.colors;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: colors.primary),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.background,
        elevation: 0,
      ),
      cardColor: colors.card,
      textTheme: const TextTheme().apply(
        bodyColor: colors.textDefault,
        displayColor: colors.textDefault,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final colors = DesignTokens.colors;
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
