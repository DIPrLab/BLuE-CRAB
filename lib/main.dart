import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_detector/bluetooth_disabled_view/bluetooth_disabled_view.dart';
import 'package:bluetooth_detector/scanner_view/scanner_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluetooth_detector/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/report/file.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:bluetooth_detector/styles/themes.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: Themes.darkMode,
    );
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  late Report report;
  late Settings settings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    await readSettings().then((settings) {
      this.settings = settings;
      print('Settings loaded');
    });
    await readReport().then((savedReport) {
      report = savedReport;
    });
    await Future.delayed(Duration(seconds: 2), () {});

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SafeArea(child: HomePage(report, settings))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: [
        Spacer(),
        Text(
          "BL(u)E CRAB",
          // style: GoogleFonts.nothingYouCouldDo(
          // style: GoogleFonts.sniglet(
          // style: GoogleFonts.caprasimo(
          // style: GoogleFonts.mogra(
          style: GoogleFonts.irishGrover(
            textStyle: TextStyles.splashText,
          ),
        ),
        Spacer(),
        SpinKitFadingCircle(
          color: Colors.white,
          size: 50.0,
        ),
        Spacer(),
      ]),
    ));
  }
}

class HomePage extends StatefulWidget {
  HomePage(Report this.report, Settings this.settings, {super.key});

  final Report report;
  final Settings settings;

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  void initState() {
    super.initState();

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? ScannerView(widget.report, widget.settings)
        : BluetoothOffView(adapterState: _adapterState);

    return InAppNotification(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: screen),
      theme: Themes.darkMode,
    ));
  }
}
