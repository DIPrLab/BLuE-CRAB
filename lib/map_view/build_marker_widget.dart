import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Widget buildMarkerWidget(BuildContext context, Offset pos, Icon icon,
        {bool backgroundCircle = true, Widget? alertContent}) =>
    Positioned(
        left: pos.dx - 24,
        top: pos.dy - 24,
        width: 48,
        height: 48,
        child: GestureDetector(
            child: Center(child: Stack(children: [if (backgroundCircle) Icon(Icons.circle, size: icon.size), icon])),
            onTap: () => alertContent == null
                ? Logger().w("No widget provided")
                : showDialog(context: context, builder: (context) => AlertDialog(content: alertContent))));
