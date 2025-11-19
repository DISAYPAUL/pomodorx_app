import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../models/progress.dart';
import '../models/quiz_analytics.dart';
import '../providers/quiz_provider.dart';
import '../routes.dart';
import '../widgets/app_bar.dart';
import '../widgets/loader.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.quizId, this.topicId});

  final String? quizId;
  final String? topicId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<QuizAnalytics?> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  Future<QuizAnalytics?> _loadAnalytics() async {
    if (widget.quizId == null) return null;
    final quizProvider = context.read<QuizProvider>();
    return quizProvider.buildQuizAnalytics(widget.quizId!);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    return Scaffold(
      appBar: const PomodoRxAppBar(title: 'Results', showBack: true),
      body: FutureBuilder<QuizAnalytics?>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenteredLoader();
          }
          final analytics = snapshot.data;
          if (analytics == null || analytics.history.isEmpty) {
            return const Center(
              child: Text('No results yet. Complete a quiz first.'),
            );
          }
          return ListView(
            padding: EdgeInsets.all(spacing.s4),
            children: [
              _ScoreSummaryCard(analytics: analytics),
              SizedBox(height: spacing.s3),
              _QuickStatsRow(analytics: analytics),
              SizedBox(height: spacing.s3),
              _FocusAreasCard(insights: analytics.focusAreas),
              SizedBox(height: spacing.s3),
              Text(
                'Attempt history',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: spacing.s1),
              _AttemptHistoryList(history: analytics.history),
              SizedBox(height: spacing.s4),
              _NavigationActions(topicId: widget.topicId),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({required this.analytics});

  final QuizAnalytics analytics;

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
            Text(
              'Latest score ${(analytics.latestPercent * 100).toStringAsFixed(0)}%',
              style: textTheme.titleMedium,
            ),
            SizedBox(height: spacing.s1),
            LinearProgressIndicator(value: analytics.latestPercent.clamp(0, 1)),
            SizedBox(height: spacing.s3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryStat(
                  label: 'Best',
                  value: '${(analytics.bestPercent * 100).toStringAsFixed(0)}%',
                ),
                _SummaryStat(
                  label: 'Average',
                  value:
                      '${(analytics.averagePercent * 100).toStringAsFixed(0)}%',
                ),
                _SummaryStat(
                  label: 'Attempts',
                  value: '${analytics.totalAttempts}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: textTheme.titleMedium),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.analytics});

  final QuizAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    final stats = [
      _QuickStat(
        label: 'Questions practiced',
        value: '${analytics.uniqueQuestions}',
      ),
      _QuickStat(
        label: 'Answers logged',
        value: '${analytics.totalItemsAnswered}',
      ),
      _QuickStat(label: 'Focus items', value: '${analytics.focusAreas.length}'),
    ];
    return Wrap(
      spacing: spacing.s2,
      runSpacing: spacing.s2,
      children: stats
          .map(
            (stat) => SizedBox(
              width: 180,
              child: Card(
                color: colors.card,
                child: Padding(
                  padding: EdgeInsets.all(spacing.s2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.value, style: textTheme.titleMedium),
                      SizedBox(height: spacing.s1 / 2),
                      Text(stat.label, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickStat {
  const _QuickStat({required this.label, required this.value});

  final String label;
  final String value;
}

class _FocusAreasCard extends StatelessWidget {
  const _FocusAreasCard({required this.insights});

  final List<QuestionInsight> insights;

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
            Text('Focus areas', style: textTheme.titleMedium),
            SizedBox(height: spacing.s2),
            if (insights.isEmpty)
              Text(
                'Great job! Nothing stands out as a weakness yet.',
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              )
            else
              ...insights.map(
                (insight) => Padding(
                  padding: EdgeInsets.only(bottom: spacing.s2),
                  child: _FocusTile(insight: insight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FocusTile extends StatelessWidget {
  const _FocusTile({required this.insight});

  final QuestionInsight insight;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    final percent = (insight.accuracy * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(insight.questionText, style: textTheme.titleSmall),
            ),
            SizedBox(width: spacing.s1),
            Text(
              '$percent%',
              style: textTheme.bodyMedium?.copyWith(color: colors.danger),
            ),
          ],
        ),
        SizedBox(height: spacing.s1 / 2),
        Text(
          '${insight.correct}/${insight.attempts} correct • Last reviewed ${_formatDate(insight.lastAttempt)}',
          style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        if (insight.explanation != null)
          Padding(
            padding: EdgeInsets.only(top: spacing.s1),
            child: Text(insight.explanation!, style: textTheme.bodySmall),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AttemptHistoryList extends StatelessWidget {
  const _AttemptHistoryList({required this.history});

  final List<UserProgress> history;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final radius = DesignTokens.radius;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, _) => SizedBox(height: spacing.s2),
      itemBuilder: (context, index) {
        final attempt = history[index];
        final pct = ((attempt.score / attempt.maxScore) * 100).toStringAsFixed(
          0,
        );
        final attemptedLabel = _formatDateTime(attempt.attemptedAt.toLocal());
        return ListTile(
          tileColor: DesignTokens.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.rMd),
          ),
          title: Text('Attempt ${index + 1} • $pct%'),
          subtitle: Text(
            'Score: ${attempt.score}/${attempt.maxScore}\n'
            '$attemptedLabel',
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _NavigationActions extends StatelessWidget {
  const _NavigationActions({required this.topicId});

  final String? topicId;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keep practicing', style: textTheme.titleMedium),
        SizedBox(height: spacing.s1),
        Text(
          'Jump back to dashboard, all topics, or reopen the difficulty & question picker for this topic.',
          style: textTheme.bodySmall,
        ),
        SizedBox(height: spacing.s2),
        Wrap(
          spacing: spacing.s2,
          runSpacing: spacing.s2,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard),
              label: const Text('Return to Dashboard'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.home);
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book),
              label: const Text('Back to topics'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.topics);
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Change difficulty & count'),
              onPressed: topicId == null
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.quizList,
                        arguments: QuizListArgs(topicId!),
                      );
                    },
            ),
          ],
        ),
      ],
    );
  }
}
