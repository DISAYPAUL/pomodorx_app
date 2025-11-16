import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    final radius = DesignTokens.radius;
    final shadows = DesignTokens.shadows;
    final colors = DesignTokens.colors;
    final background = selected ? colors.primary : colors.card;
    final textColor = selected ? colors.background : colors.textDefault;
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
            boxShadow: selected ? shadows.md : shadows.sm,
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
