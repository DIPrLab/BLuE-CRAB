import 'package:blue_crab/styles/themes.dart';
import 'package:flutter/material.dart';

TextStyle normalText = const TextStyle();
TextStyle splashText = const TextStyle(fontSize: 64, fontWeight: FontWeight.bold);
TextStyle titleText = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
TextStyle titleText2 = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

ButtonStyle buttonWithBackground = ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll(colors.foreground),
    shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))));

ButtonStyle buttonWithoutBackground = ButtonStyle(
    shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))));
