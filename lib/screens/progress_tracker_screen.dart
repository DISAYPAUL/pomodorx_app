import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../constants/design_tokens.dart';
import '../models/quiz_analytics.dart';
import '../providers/progress_provider.dart';
import '../providers/quiz_provider.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Progress'),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(spacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Study Time',
                        '${provider.totalMinutesAllTime} min',
                        Icons.timer,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(width: spacing.s3),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Sessions',
                        '${provider.totalSessionsAllTime}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.s3),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Current Streak',
                        '${provider.currentStreak} days',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: spacing.s3),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Days',
                        '${provider.progressMap.length}',
                        Icons.calendar_today,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.s3),
                _buildQuizProgressCard(context),
                SizedBox(height: spacing.s5),
                
                // Heatmap section
                Text(
                  'Activity Heatmap',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: spacing.s2),
                Text(
                  'Your study activity over the past weeks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: spacing.s3),
                
                // GitHub-style heatmap
                _buildHeatmap(context, provider),
                const SizedBox(height: 8),
                if (kDebugMode) ...[
                  ElevatedButton(
                    onPressed: () async {
                      // Quick way to add a test session for today (debug only)
                      await provider.recordSessionForDate(DateTime.now(), 25);
                    },
                    child: const Text('Add test session (debug)'),
                  ),
                  SizedBox(height: spacing.s3),
                ],
                
                SizedBox(height: spacing.s4),
                
                // Legend
                _buildLegend(context, provider),
                
                SizedBox(height: spacing.s5),
                
                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: spacing.s3),
                
                if (provider.progressList.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s5),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: spacing.s3),
                          Text(
                            'No study sessions yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: spacing.s2),
                          Text(
                            'Complete a Pomodoro session to start tracking!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...provider.progressList.take(10).map((progress) {
                    return Card(
                      margin: EdgeInsets.only(bottom: spacing.s2),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${progress.sessionsCompleted}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE, MMMM d, y').format(progress.date),
                        ),
                        subtitle: Text(
                          '${progress.totalMinutes} minutes studied',
                        ),
                        trailing: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    );
                  }),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final spacing = DesignTokens.spacing;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: spacing.s2),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.s1),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizProgressCard(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final quizProvider = context.read<QuizProvider>();

    return FutureBuilder<GlobalAnalytics?>(
      future: quizProvider.buildGlobalAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(spacing.s3),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: spacing.s2),
                  const Expanded(
                    child: Text('Loading quiz progress...'),
                  ),
                ],
              ),
            ),
          );
        }

        final analytics = snapshot.data;
        if (analytics == null || !analytics.hasData) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(spacing.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz, color: colors.primary),
                      SizedBox(width: spacing.s2),
                      Text(
                        'Quiz Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.s2),
                  Text(
                    'Complete a quiz to unlock accuracy and mastery insights.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          );
        }

        final avgPercent = (analytics.averagePercent * 100).clamp(0, 100);
        final bestPercent = (analytics.bestPercent * 100).clamp(0, 100);
        final lastAttempt = analytics.lastAttempt;

        return Card(
          child: Padding(
            padding: EdgeInsets.all(spacing.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz, color: colors.primary),
                    SizedBox(width: spacing.s2),
                    Text(
                      'Quiz Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: spacing.s3),
                Wrap(
                  spacing: spacing.s3,
                  runSpacing: spacing.s2,
                  children: [
                    _buildQuizStatChip(
                      context,
                      label: 'Attempts',
                      value: '${analytics.totalAttempts}',
                    ),
                    _buildQuizStatChip(
                      context,
                      label: 'Avg Score',
                      value: '${avgPercent.toStringAsFixed(0)}%',
                    ),
                    _buildQuizStatChip(
                      context,
                      label: 'Best Score',
                      value: '${bestPercent.toStringAsFixed(0)}%',
                    ),
                    _buildQuizStatChip(
                      context,
                      label: 'Last Attempt',
                      value: lastAttempt != null
                          ? DateFormat('MMM d • h:mm a').format(lastAttempt)
                          : '—',
                    ),
                  ],
                ),
                SizedBox(height: spacing.s3),
                LinearProgressIndicator(
                  value: (avgPercent / 100).clamp(0.0, 1.0),
                  backgroundColor: colors.card,
                  color: colors.accent,
                  minHeight: 6,
                ),
                SizedBox(height: spacing.s1),
                Text(
                  'Average accuracy ${avgPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizStatChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: Container(
        padding: EdgeInsets.all(spacing.s2),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(DesignTokens.radius.rSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: spacing.s1 / 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, ProgressProvider provider) {
    final now = DateTime.now();
    const int weeks = 17; // show ~4 months

    // Align startDate to the start of the week (Monday) so columns map to
    // complete weeks and we don't miss days.
    final endOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - DateTime.monday));
    final startDate = endOfWeek.subtract(Duration(days: (weeks - 1) * 7));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekday labels
          Row(
            children: [
              const SizedBox(width: 30),
              // Month labels above each week column
              ..._buildMonthLabels(startDate, weeks),
              // Space for the heatmap columns above — month labels are aligned
              // with each week column, so there's no extra placeholder needed.
            ],
          ),
          
          // Heatmap grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    // Week columns — reserve width for the week columns.
                    ...List.generate(weeks, (weekIndex) {
                      return const SizedBox(width: 14); // spacing to match heatmap col
                    }),
                  _buildDayLabel('Wed', context),
                  _buildDayLabel('', context),
                  _buildDayLabel('Fri', context),
                  _buildDayLabel('', context),
                  _buildDayLabel('Sun', context),
                ],
              ),
              
              // Heatmap cells
              ...List.generate(weeks, (weekIndex) {
                return Column(
                  children: List.generate(7, (dayIndex) {
                    final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                    if (date.isAfter(now)) {
                      return _buildEmptyCell();
                    }
                    final progress = provider.getProgressForDate(date);
                    final level = provider.getIntensityLevel(progress);
                    return _buildHeatmapCell(
                      context,
                      provider,
                      date,
                      progress,
                      level,
                    );
                  }),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label, BuildContext context) {
    return SizedBox(
      width: 30,
      height: 14,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: Colors.grey,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
    );
  }

  Widget _buildHeatmapCell(
    BuildContext context,
    ProgressProvider provider,
    DateTime date,
    dynamic progress,
    int level,
  ) {
    return Tooltip(
      message: progress != null
          ? '${DateFormat('MMM d, y').format(date)}\n${progress.totalMinutes} min, ${progress.sessionsCompleted} sessions'
          : '${DateFormat('MMM d, y').format(date)}\nNo activity',
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: provider.getIntensityColor(level, context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ProgressProvider provider) {
    return Row(
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: provider.getIntensityColor(index, context),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'More',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

  // Build month labels above weeks — we show the month name at the column
  // where the month first appears (similar to GitHub heatmap).
  List<Widget> _buildMonthLabels(DateTime startDate, int weeks) {
    final labels = <Widget>[];

    labels.add(const SizedBox(width: 30));

    String? lastMonth;
    for (int w = 0; w < weeks; w++) {
      final weekStart = startDate.add(Duration(days: w * 7));
      final monthName = DateFormat('MMM').format(weekStart);

      if (lastMonth == null || weekStart.month != startDate.add(Duration(days: (w - 1) * 7)).month) {
        labels.add(Container(
          width: 14,
          alignment: Alignment.centerLeft,
          child: Text(
            monthName,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ));
      } else {
        labels.add(Container(width: 14));
      }

      lastMonth = monthName;
    }

    return labels;
  }
