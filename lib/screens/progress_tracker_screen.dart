import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/progress_provider.dart';

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

  Widget _buildHeatmap(BuildContext context, ProgressProvider provider) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 119)); // ~4 months
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekday labels
          Row(
            children: [
              const SizedBox(width: 30),
              ...List.generate(17, (weekIndex) {
                return Container(
                  width: 50,
                  child: const SizedBox(),
                );
              }),
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
                  _buildDayLabel('Mon', context),
                  _buildDayLabel('', context),
                  _buildDayLabel('Wed', context),
                  _buildDayLabel('', context),
                  _buildDayLabel('Fri', context),
                  _buildDayLabel('', context),
                  _buildDayLabel('Sun', context),
                ],
              ),
              
              // Heatmap cells
              ...List.generate(17, (weekIndex) {
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
