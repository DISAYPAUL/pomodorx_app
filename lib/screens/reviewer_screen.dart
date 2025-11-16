import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/quiz_provider.dart';
import '../providers/reviewer_provider.dart';
import '../providers/topic_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/loader.dart';
import '../widgets/toast.dart';

class ReviewerScreen extends StatefulWidget {
  const ReviewerScreen({super.key, required this.topicId});

  final String topicId;

  @override
  State<ReviewerScreen> createState() => _ReviewerScreenState();
}

class _ReviewerScreenState extends State<ReviewerScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final quizProvider = context.read<QuizProvider>();
    await quizProvider.loadQuizzes(widget.topicId);
    await context.read<ReviewerProvider>().loadCached(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final topic = context.read<TopicProvider>().findById(widget.topicId);
    return Scaffold(
      appBar: PomodoRxAppBar(
        title: topic?.name ?? 'Reviewer',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => context.read<ReviewerProvider>().speakCurrent(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Consumer2<ReviewerProvider, QuizProvider>(
          builder: (context, reviewerProvider, quizProvider, _) {
            if (reviewerProvider.isLoading || quizProvider.isLoading) {
              return const CenteredLoader();
            }
            final reviewer = reviewerProvider.current;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reviewer == null)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No reviewer generated yet.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: colors.textMuted),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        reviewer.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                SizedBox(height: spacing.s2),
                ElevatedButton(
                  onPressed: quizProvider.quizzes.isEmpty
                      ? () => showToast(
                            context,
                            'No quizzes available to generate a reviewer.',
                          )
                      : () async {
                          if (topic == null) return;
                          await reviewerProvider.generateLocalReviewer(
                            topic,
                            quizProvider.quizzes,
                          );
                        },
                  child: const Text('Generate Reviewer'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
