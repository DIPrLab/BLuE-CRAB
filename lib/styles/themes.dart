import 'package:flutter/material.dart';

// ignore: camel_case_types
class colors {
  static const Color transparent = Color(0x00000000);

  static const Color background = Color(0xFF4f5d75);
  static const Color foreground = Color(0xFF2D3142);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color iconColor = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBFC0C0);
  static const Color altText = Color(0xFFF6AA1C);
  static const Color warnText = Color(0xFFBB4430);
  static const Color safeText = Color(0xFF8CD867);
}

ThemeData darkMode = ThemeData(
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.dark,
      // used
      primaryContainer: colors.foreground,
      onPrimaryContainer: colors.primaryText,
      primary: colors.altText,
      surface: colors.background,
      onSurface: colors.primaryText,
      surfaceContainerHighest: colors.foreground,
      onSurfaceVariant: colors.primaryText,
      outlineVariant: colors.foreground,
    ));
