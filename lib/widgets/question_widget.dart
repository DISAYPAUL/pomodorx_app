import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';
import '../models/question.dart';
import 'option_tile.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.onOptionSelected,
    this.readOnly = false,
  });

  final Question question;
  final int? selectedIndex;
  final ValueChanged<int> onOptionSelected;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final colors = DesignTokens.colors;
    final hasSelection = selectedIndex != null;
    final isCorrect = hasSelection && selectedIndex == question.correctIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: spacing.s3),
        ...question.options.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(bottom: spacing.s2),
            child: OptionTile(
              label: entry.value,
              feedback: _optionFeedback(entry.key),
              disabled: readOnly,
              onTap: () => onOptionSelected(entry.key),
            ),
          ),
        ),
        if (!readOnly && hasSelection) ...[
          SizedBox(height: spacing.s2),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.s2),
            decoration: BoxDecoration(
              color: (isCorrect ? colors.success : colors.danger).withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius.rMd),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.error_outline,
                  color: isCorrect ? colors.success : colors.danger,
                ),
                SizedBox(width: spacing.s1),
                Expanded(
                  child: Text(
                    isCorrect ? 'Correct' : 'Incorrect',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCorrect ? colors.success : colors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (!isCorrect)
            Padding(
              padding: EdgeInsets.only(top: spacing.s1),
              child: Text(
                question.explanation ?? 'Review the rationale in your notes and try again.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.textMuted),
              ),
            ),
        ]
        else if (readOnly && question.explanation != null) ...[
          SizedBox(height: spacing.s2),
          Text(
            'Explanation:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            question.explanation!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.textMuted),
          ),
        ],
      ],
    );
  }

  OptionFeedback _optionFeedback(int optionIndex) {
    if (readOnly) {
      if (question.correctIndex == optionIndex) {
        return OptionFeedback.correct;
      }
      if (selectedIndex == optionIndex && selectedIndex != question.correctIndex) {
        return OptionFeedback.incorrect;
      }
      return OptionFeedback.neutral;
    }
    if (selectedIndex == null) return OptionFeedback.neutral;
    if (optionIndex == question.correctIndex) {
      return OptionFeedback.correct;
    }
    if (optionIndex == selectedIndex) {
      return OptionFeedback.incorrect;
    }
    return OptionFeedback.neutral;
  }
}
