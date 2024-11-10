import 'package:flutter/material.dart';

// ignore: camel_case_types
class colors {
  static const Color transparent = Color(0x00000000);

  static const Color background = Color(0xFF4f5d75);
  static const Color foreground = Color(0xFF2D3142);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color iconColor = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBFC0C0);
  static const Color altText = Color(0xFFEF8354);

  // static const Color background = Color(0xFF304D6D);
  // static const Color primaryText = Color(0xFFFFFFFF);
  // static const Color iconColor = Color(0xFFFFFFFF);
  // static const Color foreground = Color(0xFF82A0BC);
  // static const Color secondaryText = Color(0xFFFF0000);
  // static const Color altText = Color(0xFFFF0000);

  // static const Color background = Color(0xFF1C4E80);
  // static const Color primaryText = Color(0xFFFFFFFF);
  // static const Color iconColor = Color(0xFFFFFFFF);
  // static const Color foreground = Color(0xFF87CEEB);
  // static const Color secondaryText = Color(0xFFF4A460);
  // static const Color altText = Color(0xFFDC143C);

  // static const Color background = Color(0xFF000080);
  // static const Color primaryText = Color(0xFFF5F5F5);
  // static const Color iconColor = Color(0xFFF5F5F5);
  // static const Color foreground = Color(0xFF87CEEB);
  // // static const Color secondaryText = Color(0xFFF4A460);
  // static const Color altText = Color(0xFFB22222);
}

class Themes {
  // highlightColor: Colors.red,
  static ThemeData darkMode = ThemeData(
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
      ).copyWith(
          // not used
          // onPrimary: Colors.yellow,
          // primaryFixed: Colors.yellow,
          // primaryFixedDim: Colors.yellow,
          // onPrimaryFixed: Colors.yellow,
          // onPrimaryFixedVariant: Colors.yellow,
          // secondary: Colors.yellow,
          // onSecondary: Colors.yellow,
          // secondaryContainer: Colors.yellow,
          // onSecondaryContainer: Colors.yellow,
          // secondaryFixed: Colors.yellow,
          // secondaryFixedDim: Colors.yellow,
          // onSecondaryFixed: Colors.yellow,
          // onSecondaryFixedVariant: Colors.yellow,
          // tertiary: Colors.yellow,
          // onTertiary: Colors.yellow,
          // tertiaryContainer: Colors.yellow,
          // onTertiaryContainer: Colors.yellow,
          // tertiaryFixed: Colors.yellow,
          // tertiaryFixedDim: Colors.yellow,
          // onTertiaryFixed: Colors.yellow,
          // onTertiaryFixedVariant: Colors.yellow,
          // error: Colors.yellow,
          // onError: Colors.yellow,
          // errorContainer: Colors.yellow,
          // onErrorContainer: Colors.yellow,
          // surfaceDim: Colors.red,
          // surfaceBright: Colors.red,
          // surfaceContainerLowest: Colors.red,
          // surfaceContainerLow: Colors.red,
          // surfaceContainer: Colors.red,
          // surfaceContainerHigh: Colors.red,
          // outline: Colors.red,
          // shadow: Colors.red,
          // scrim: Colors.blue,
          // inverseSurface: Colors.blue,
          // onInverseSurface: Colors.blue,
          // inversePrimary: Colors.blue,
          // surfaceTint: Colors.blue,
          ));
}
