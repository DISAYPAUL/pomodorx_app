import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/card_topic.dart';
import '../widgets/loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'PomodoRx'),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: ListView(
          children: [
            // Pomodoro Timer Feature Card
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.pomodoro),
                child: Padding(
                  padding: EdgeInsets.all(spacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: spacing.s3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pomodoro Timer',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: spacing.s1),
                                Text(
                                  'Start your focus session',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.s3),
                      Consumer<PomodoroProvider>(
                        builder: (context, provider, _) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildQuickStat(
                                  context,
                                  'Sessions Today',
                                  '${provider.completedWorkSessions}',
                                  Icons.check_circle,
                                ),
                              ),
                              SizedBox(width: spacing.s2),
                              Expanded(
                                child: _buildQuickStat(
                                  context,
                                  'Current Status',
                                  provider.sessionLabel,
                                  Icons.info_outline,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.s4),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.s2),
            Wrap(
              spacing: spacing.s2,
              runSpacing: spacing.s2,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.pomodoro,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Timer'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.progress,
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Progress'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.topics,
                  ),
                  icon: const Icon(Icons.book),
                  label: const Text('Browse Topics'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.settings,
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ],
            ),
            SizedBox(height: spacing.s4),
            
            // Featured Topics
            Consumer<TopicProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.topics.isEmpty) {
                  return const CenteredLoader();
                }
                final topics = provider.topics.take(3).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Topics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: spacing.s2),
                    if (topics.isEmpty)
                      Text(
                        'No topics yet. Import data from Settings.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colors.textMuted),
                      )
                    else
                      ...topics.map(
                        (topic) => TopicCard(
                          topic: topic,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.topicDetail,
                            arguments: TopicDetailArgs(topic.id),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final spacing = DesignTokens.spacing;
    return Container(
      padding: EdgeInsets.all(spacing.s2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          SizedBox(height: spacing.s1),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
