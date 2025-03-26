import 'dart:async';
import 'package:blue_crab/bluetooth_disabled_view/bluetooth_disabled_view.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/scanner_view/scanner_view.dart';
import 'package:blue_crab/styles/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() => super.initState();

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) =>
      // MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen(), theme: Themes.darkMode);
      MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage(), theme: Themes.darkMode);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  Report report = Report({});

  @override
  void initState() {
    super.initState();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) => setState(() => _adapterState = state));
    _loadData();
  }

  @override
  void dispose() => super.dispose();

  Future<void> _loadData() async {
    readReport().then((savedReport) => report.combine(savedReport));
    readSettings();
  }

  @override
  Widget build(BuildContext context) => InAppNotification(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SafeArea(
              child: _adapterState == BluetoothAdapterState.on
                  ? ScannerView(report)
                  : BluetoothOffView(adapterState: _adapterState)),
          theme: Themes.darkMode));
}
