import 'package:flutter/material.dart';

/// DesignTokens centralizes Tailwind-like values for consistent styling.
class DesignTokens {
  DesignTokens._();

  static _ColorTokens get colors => _ColorTokens();
  static _SpacingTokens get spacing => _SpacingTokens();
  static _RadiusTokens get radius => _RadiusTokens();
  static _TextSizeTokens get textSizes => _TextSizeTokens();
  static _ShadowTokens get shadows => _ShadowTokens();
}

class _ColorTokens {
  final Color primary = const Color(0xFFEC4899);
  final Color primaryDark = const Color(0xFFBE185D);
  final Color accent = const Color(0xFF06B6D4);
  final Color background = const Color(0xFFFFFFFF);
  final Color card = const Color(0xFFF8F8F9);
  final Color textDefault = const Color(0xFF111827);
  final Color textMuted = const Color(0xFF6B7280);
  final Color success = const Color(0xFF10B981);
  final Color danger = const Color(0xFFEF4444);
}

class _SpacingTokens {
  final double s0 = 4;
  final double s1 = 8;
  final double s2 = 12;
  final double s3 = 16;
  final double s4 = 24;
  final double s5 = 32;
}

class _RadiusTokens {
  final double rSm = 6;
  final double rMd = 12;
  final double rLg = 20;
}

class _TextSizeTokens {
  final double xs = 12;
  final double sm = 14;
  final double base = 16;
  final double lg = 20;
  final double xl = 24;
  final double twoXl = 32;
}

class _ShadowTokens {
  final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
