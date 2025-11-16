import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';
import '../models/topic.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({super.key, required this.topic, required this.onTap});

  final Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final radius = DesignTokens.radius;
    final shadows = DesignTokens.shadows;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.s3),
        padding: EdgeInsets.all(spacing.s3),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(radius.rMd),
          boxShadow: shadows.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.accent,
              child: Text(topic.name.characters.first.toUpperCase()),
            ),
            SizedBox(width: spacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
