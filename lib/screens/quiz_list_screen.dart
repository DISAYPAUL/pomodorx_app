import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/quiz_provider.dart';
import '../providers/topic_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/loader.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key, required this.topicId});

  final String topicId;

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizProvider>().loadQuizzes(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final radius = DesignTokens.radius;
    final topic = context.read<TopicProvider>().findById(widget.topicId);
    return Scaffold(
      appBar: PomodoRxAppBar(
        title: topic?.name ?? 'Quizzes',
        showBack: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Consumer<QuizProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const CenteredLoader();
            }
            if (provider.quizzes.isEmpty) {
              return const Center(child: Text('No quizzes yet.'));
            }
            return ListView.separated(
              itemCount: provider.quizzes.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.s2),
              itemBuilder: (context, index) {
                final quiz = provider.quizzes[index];
                return ListTile(
                  tileColor: DesignTokens.colors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius.rMd),
                  ),
                  title: Text(quiz.title),
                  subtitle: Text(
                    '${quiz.questions.length} questions • '
                    '${quiz.durationMinutes ?? 0} mins',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    provider.startQuiz(quiz);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.quizPlay,
                      arguments: QuizPlayArgs(quiz: quiz),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
