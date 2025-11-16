import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';

class PomodoRxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PomodoRxAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = DesignTokens.colors;
    return AppBar(
      backgroundColor: colors.primary,
      foregroundColor: colors.background,
      automaticallyImplyLeading: showBack,
      title: Text(title),
      actions: actions,
    );
  }
}
