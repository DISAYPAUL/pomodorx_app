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
          Consumer<ReviewerProvider>(
            builder: (_, provider, __) {
              final hasReviewer = provider.current != null;
              return IconButton(
                icon: Icon(provider.isSpeaking ? Icons.stop : Icons.volume_up),
                tooltip: provider.isSpeaking
                    ? 'Stop text-to-speech'
                    : 'Play text-to-speech',
                onPressed: hasReviewer
                    ? () {
                        if (provider.isSpeaking) {
                          provider.stopSpeaking();
                        } else {
                          provider.speakCurrent();
                        }
                      }
                    : null,
              );
            },
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
                _GenerateHint(hasReviewer: reviewer != null),
                SizedBox(height: spacing.s2),
                if (reviewer == null)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No reviewer generated yet.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.textMuted,
                        ),
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
                if (reviewerProvider.isSpeaking)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.s1),
                    child: TextButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit text-to-speech'),
                      onPressed: reviewerProvider.stopSpeaking,
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
                  child: const Text('Generate Topic Module'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GenerateHint extends StatelessWidget {
  const _GenerateHint({required this.hasReviewer});

  final bool hasReviewer;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: colors.card,
      child: Padding(
        padding: EdgeInsets.all(spacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              hasReviewer ? Icons.menu_book : Icons.touch_app,
              color: colors.primary,
            ),
            SizedBox(width: spacing.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasReviewer ? 'Module ready' : 'Generate a topic module',
                    style: textTheme.titleMedium,
                  ),
                  SizedBox(height: spacing.s1),
                  Text(
                    'Tap “Generate Topic Module” to compile professor-style notes for the whole topic. The module explains learning outcomes, cues, and drills—separate from any single quiz.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
