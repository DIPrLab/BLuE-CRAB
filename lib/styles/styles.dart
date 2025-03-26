import 'package:blue_crab/styles/themes.dart';
import 'package:flutter/material.dart';

class TextStyles {
  static var normal = const TextStyle();
  static var splashText = const TextStyle(fontSize: 64, fontWeight: FontWeight.bold);
  static var title = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static var title2 = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}

class AppButtonStyle {
  static ButtonStyle buttonWithBackground = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(colors.foreground),
      shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))));

  static ButtonStyle buttonWithoutBackground = ButtonStyle(
      shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))));
}
