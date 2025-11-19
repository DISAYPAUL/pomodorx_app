import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Topic Detail', showBack: true),
      body: Consumer<TopicProvider>(
        builder: (context, provider, _) {
          final topic = provider.findById(topicId);
          if (topic == null) {
            return const Center(child: Text('Topic not found.'));
          }
          return Padding(
            padding: EdgeInsets.all(spacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: spacing.s2),
                Text(
                  topic.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.textMuted),
                ),
                if (topic.detailedDescription != null) ...[
                  SizedBox(height: spacing.s4),
                  Text(
                    'About This Topic',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: spacing.s2),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        topic.detailedDescription!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.s4),
                ] else
                  const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.quizList,
                    arguments: QuizListArgs(topic.id),
                  ),
                  icon: const Icon(Icons.quiz),
                  label: const Text('View quizzes'),
                ),
                SizedBox(height: spacing.s2),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.reviewer,
                    arguments: ReviewerArgs(topic.id),
                  ),
                  icon: const Icon(Icons.article),
                  label: const Text('Generate reviewer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
