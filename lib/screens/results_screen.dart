import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../models/progress.dart';
import '../providers/quiz_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/loader.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.quizId});

  final String? quizId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<UserProgress>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<UserProgress>> _loadHistory() async {
    if (widget.quizId == null) return [];
    final quizProvider = context.read<QuizProvider>();
    return quizProvider.historyForQuiz(widget.quizId!);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final radius = DesignTokens.radius;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Results', showBack: true),
      body: Padding(
        padding: EdgeInsets.all(spacing.s4),
        child: FutureBuilder<List<UserProgress>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CenteredLoader();
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const Center(
                child: Text('No results yet. Complete a quiz first.'),
              );
            }
            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => SizedBox(height: spacing.s2),
              itemBuilder: (context, index) {
                final item = history[index];
                final scorePct =
                    ((item.score / item.maxScore) * 100).toStringAsFixed(0);
                return ListTile(
                  tileColor: DesignTokens.colors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius.rMd),
                  ),
                  title: Text('Attempt ${index + 1} • $scorePct%'),
                  subtitle: Text(
                    'Score: ${item.score}/${item.maxScore}\n${item.attemptedAt.toLocal()}',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
