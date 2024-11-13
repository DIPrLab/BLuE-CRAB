import 'package:flutter/material.dart';
import 'package:bluetooth_detector/styles/themes.dart';

class TextStyles {
  static var normal = const TextStyle();
  static var splashText = const TextStyle(fontSize: 64.0, fontWeight: FontWeight.bold);
  static var title = const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);
  static var title2 = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
}

class AppButtonStyle {
  static ButtonStyle buttonWithBackground = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(colors.foreground),
      shape:
          WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))));

  static ButtonStyle buttonWithoutBackground = ButtonStyle(
      shape:
          WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))));
}
