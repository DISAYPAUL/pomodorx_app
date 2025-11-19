import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer bootstrap until after first frame to avoid provider notifications
    // during the initial widget build phase which can cause "setState() or
    // markNeedsBuild() called during build" exceptions.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final topicProvider = context.read<TopicProvider>();
    await topicProvider.bootstrap();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CenteredLoader(message: 'Loading PomodoRx...'));
  }
}
