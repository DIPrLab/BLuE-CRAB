import 'package:blue_crab/bluetooth_disabled_view/bluetooth_disabled_view.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/scanner_view/scanner_view.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage(), theme: darkMode);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) => setState(() => _adapterState = state));
    readSettings();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => InAppNotification(
      child: _adapterState == BluetoothAdapterState.on
          ? const ScannerView()
          : BluetoothOffView(adapterState: _adapterState));
}
