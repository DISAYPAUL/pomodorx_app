import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../models/quiz_analytics.dart';
import '../providers/quiz_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/global_analytics_dashboard.dart';
import '../widgets/loader.dart';

class QuizDashboardScreen extends StatefulWidget {
  const QuizDashboardScreen({super.key});

  @override
  State<QuizDashboardScreen> createState() => _QuizDashboardScreenState();
}

class _QuizDashboardScreenState extends State<QuizDashboardScreen> {
  late Future<GlobalAnalytics?> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  Future<GlobalAnalytics?> _loadAnalytics() {
    final quizProvider = context.read<QuizProvider>();
    return quizProvider.buildGlobalAnalytics();
  }

  Future<void> _refreshAnalytics() async {
    final future = _loadAnalytics();
    setState(() {
      _analyticsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Quiz Hub', showBack: false),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        child: FutureBuilder<GlobalAnalytics?>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CenteredLoader();
            }

            final analytics = snapshot.data;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(spacing.s4),
              children: [
                if (analytics != null && analytics.hasData)
                  GlobalAnalyticsDashboard(
                    analytics: analytics,
                    onViewDetails: () {
                      Navigator.pushNamed(context, AppRoutes.progress);
                    },
                  )
                else ...[
                  Text(
                    'Track your mastery',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: spacing.s1),
                  Text(
                    'Complete a quiz to unlock personalized analytics across every topic and difficulty.',
                    style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                  ),
                  SizedBox(height: spacing.s3),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.topics),
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Take your first quiz'),
                  ),
                ],
                SizedBox(height: spacing.s4),
                _QuickActionsCard(onBrowseTopics: () {
                  Navigator.pushNamed(context, AppRoutes.topics);
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.onBrowseTopics});

  final VoidCallback onBrowseTopics;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: colors.card,
      child: Padding(
        padding: EdgeInsets.all(spacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keep the streak going', style: textTheme.titleMedium),
            SizedBox(height: spacing.s1),
            Text(
              'Jump into any topic to practice with refreshed 100-question banks, or revisit results from the dashboard above.',
              style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
            SizedBox(height: spacing.s3),
            ElevatedButton.icon(
              onPressed: onBrowseTopics,
              icon: const Icon(Icons.list_alt),
              label: const Text('Browse Topics'),
            ),
          ],
        ),
      ),
    );
  }
}
