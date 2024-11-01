import 'package:flutter/material.dart';

Widget buildMarkerWidget(BuildContext context, Offset pos, Icon icon, bool backgroundCircle) => Positioned(
    left: pos.dx - 24,
    top: pos.dy - 24,
    width: 48,
    height: 48,
    child: GestureDetector(
        child: Center(child: Stack(children: [if (backgroundCircle) Icon(Icons.circle, size: icon.size), icon])),
        onTap: () =>
            showDialog(context: context, builder: (context) => const AlertDialog(content: Text("Data Here")))));
