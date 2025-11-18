import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';
import '../models/quiz_analytics.dart';

class GlobalAnalyticsDashboard extends StatelessWidget {
  const GlobalAnalyticsDashboard({super.key, required this.analytics, this.onViewDetails});

  final GlobalAnalytics analytics;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    final topicCards = analytics.topicStats
        .map(
          (topic) => Padding(
            padding: EdgeInsets.only(bottom: spacing.s3),
            child: _TopicAnalyticsCard(topic: topic),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your study snapshot',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (onViewDetails != null)
              TextButton(
                onPressed: onViewDetails,
                child: const Text('View details'),
              ),
          ],
        ),
        SizedBox(height: spacing.s2),
        Card(
          color: colors.card,
          child: Padding(
            padding: EdgeInsets.all(spacing.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_percentLabel(analytics.averagePercent)} average • ${analytics.totalAttempts} attempts',
                  style: textTheme.titleMedium,
                ),
                SizedBox(height: spacing.s1),
                LinearProgressIndicator(value: analytics.averagePercent.clamp(0, 1)),
                SizedBox(height: spacing.s2),
                Wrap(
                  spacing: spacing.s3,
                  runSpacing: spacing.s1,
                  children: [
                    _SummaryChip(
                      label: 'Best score',
                      value: _percentLabel(analytics.bestPercent),
                    ),
                    _SummaryChip(
                      label: 'Last attempt',
                      value: analytics.lastAttempt != null
                          ? _formatDate(analytics.lastAttempt!)
                          : 'Not yet started',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.s3),
        if (topicCards.isEmpty)
          Text(
            'Complete a quiz to unlock your analytics dashboard.',
            style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
          )
        else
          ...topicCards,
      ],
    );
  }

  String _percentLabel(double fraction) {
    return '${(fraction * 100).clamp(0, 100).toStringAsFixed(0)}%';
  }

  String _formatDate(DateTime dateTime) {
    final date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s2,
        vertical: spacing.s1,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(DesignTokens.radius.rSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: textTheme.titleSmall),
          Text(label, style: textTheme.bodySmall?.copyWith(color: colors.textMuted)),
        ],
      ),
    );
  }
}

class _TopicAnalyticsCard extends StatelessWidget {
  const _TopicAnalyticsCard({required this.topic});

  final TopicPerformance topic;

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
            Text(topic.topicName, style: textTheme.titleMedium),
            SizedBox(height: spacing.s1),
            Row(
              children: [
                Text(
                  _percentLabel(topic.averagePercent),
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: spacing.s2),
                Text(
                  '${topic.totalAttempts} attempts',
                  style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
            if (topic.lastAttempt != null) ...[
              SizedBox(height: spacing.s1),
              Text(
                'Last reviewed: ${_formatDate(topic.lastAttempt!)}',
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
            SizedBox(height: spacing.s2),
            Wrap(
              spacing: spacing.s2,
              runSpacing: spacing.s1,
              children: topic.difficultyStats.map((diff) {
                return _DifficultyPill(stat: diff);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _percentLabel(double fraction) {
    return '${(fraction * 100).clamp(0, 100).toStringAsFixed(0)}%';
  }

  String _formatDate(DateTime dateTime) {
    final date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.stat});

  final DifficultyPerformance stat;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s2,
        vertical: spacing.s1,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(DesignTokens.radius.rSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.label, style: textTheme.bodyMedium),
          SizedBox(height: spacing.s1 / 2),
          Text(
            '${_percentLabel(stat.averagePercent)} avg • best ${_percentLabel(stat.bestPercent)}',
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
          Text(
            '${stat.attempts} attempts',
            style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  String _percentLabel(double fraction) {
    return '${(fraction * 100).clamp(0, 100).toStringAsFixed(0)}%';
  }
}
