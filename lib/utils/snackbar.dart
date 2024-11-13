// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// enum ABC {
//   a,
//   b,
//   c,
// }

// class Snackbar {
//   static final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
//   static final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
//   static final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

//   static GlobalKey<ScaffoldMessengerState> getSnackbar(ABC abc) => abc == ABC.a
//       ? snackBarKeyA
//       : abc == ABC.b
//           ? snackBarKeyB
//           : snackBarKeyC;

//   static show(ABC abc, String msg, {required bool success}) {
//     final snackBar = success
//         ? SnackBar(content: Text(msg), backgroundColor: Colors.blue)
//         : SnackBar(content: Text(msg), backgroundColor: Colors.red);
//     getSnackbar(abc).currentState?.removeCurrentSnackBar();
//     getSnackbar(abc).currentState?.showSnackBar(snackBar);
//   }
// }

// String prettyException(String prefix, dynamic e) => e is FlutterBluePlusException
//     ? "$prefix ${e.description}"
//     : e is PlatformException
//         ? "$prefix ${e.message}"
//         : prefix + e.toString();
