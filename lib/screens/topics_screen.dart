import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/card_topic.dart';
import '../widgets/loader.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Topics', showBack: true),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search topics',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: context.read<TopicProvider>().setSearchQuery,
            ),
            SizedBox(height: spacing.s3),
            Expanded(
              child: Consumer<TopicProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const CenteredLoader();
                  }
                  if (provider.topics.isEmpty) {
                    return const Center(
                      child: Text('No topics available yet.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.topics.length,
                    itemBuilder: (context, index) {
                      final topic = provider.topics[index];
                      return TopicCard(
                        topic: topic,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.topicDetail,
                          arguments: TopicDetailArgs(topic.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
