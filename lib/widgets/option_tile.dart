import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';

enum OptionFeedback { neutral, correct, incorrect }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.feedback,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final OptionFeedback feedback;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final radius = DesignTokens.radius;
    final shadows = DesignTokens.shadows;
    final colors = DesignTokens.colors;
    Color background;
    Color textColor;
    switch (feedback) {
      case OptionFeedback.correct:
        background = colors.success.withOpacity(0.15);
        textColor = colors.success;
        break;
      case OptionFeedback.incorrect:
        background = colors.danger.withOpacity(0.15);
        textColor = colors.danger;
        break;
      case OptionFeedback.neutral:
        background = colors.card;
        textColor = colors.textDefault;
        break;
    }
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(radius.rMd),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.s3),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius.rMd),
            boxShadow: feedback == OptionFeedback.neutral
                ? shadows.sm
                : feedback == OptionFeedback.incorrect
                    ? [
                        BoxShadow(
                          color: colors.danger.withOpacity(0.15),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: colors.success.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
          ),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
