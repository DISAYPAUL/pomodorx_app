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
              selected: selectedIndex == entry.key,
              disabled: readOnly,
              onTap: () => onOptionSelected(entry.key),
            ),
          ),
        ),
        if (readOnly && question.explanation != null) ...[
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
}
