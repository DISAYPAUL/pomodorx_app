import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/question_widget.dart';
import '../widgets/toast.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizProvider>().startQuiz(widget.quiz);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    return Scaffold(
      appBar: PomodoRxAppBar(title: widget.quiz.title, showBack: true),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: Consumer<QuizProvider>(
          builder: (context, provider, _) {
            final question = provider.currentQuestion;
            if (question == null) {
              return const Center(child: Text('Question not available.'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${provider.currentIndex + 1} of '
                  '${widget.quiz.questions.length}',
                ),
                SizedBox(height: spacing.s2),
                Expanded(
                  child: SingleChildScrollView(
                    child: QuestionWidget(
                      question: question,
                      selectedIndex: provider.answers[question.id],
                      onOptionSelected: (index) =>
                          provider.selectAnswer(question.id, index),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: provider.currentIndex == 0
                          ? null
                          : provider.previousQuestion,
                      child: const Text('Previous'),
                    ),
                    TextButton(
                      onPressed:
                          provider.currentIndex ==
                              widget.quiz.questions.length - 1
                          ? null
                          : provider.nextQuestion,
                      child: const Text('Next'),
                    ),
                  ],
                ),
                SizedBox(height: spacing.s2),
                ElevatedButton(
                  onPressed: () async {
                    if (!provider.isQuizCompleted) {
                      showToast(
                        context,
                        'Answer all questions before submitting.',
                      );
                      return;
                    }
                    final progress = await provider.submitQuiz();
                    if (!mounted || progress == null) return;
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.results,
                      arguments: ResultsArgs(
                        quizId: widget.quiz.id,
                        topicId: widget.quiz.topicId,
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
