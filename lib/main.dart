import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:blue_crab/bluetooth_disabled_view/bluetooth_disabled_view.dart';
import 'package:blue_crab/scanner_view/scanner_view.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/filesystem/filesystem.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/styles/themes.dart';
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
      MaterialApp(debugShowCheckedModeBanner: false, home: HomePage(), theme: Themes.darkMode);
}

// class SplashScreen extends StatefulWidget {
//   SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreen();
// }

// class _SplashScreen extends State<SplashScreen> {
//   Report report = Report({});
//   late Settings settings;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() => super.dispose();

//   Future<void> _loadData() async {
//     readReport().then((savedReport) => report.combine(savedReport));
//     await readSettings().then((settings) => this.settings = settings);
//     await Future.delayed(Duration(seconds: 2), () {});

//     Navigator.push(context, MaterialPageRoute(builder: (context) => SafeArea(child: HomePage(report, settings))));
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//           body: Center(
//               child: Column(children: [
//         Spacer(),
//         Text("BL(u)E CRAB",
//             // style: GoogleFonts.nothingYouCouldDo(
//             // style: GoogleFonts.sniglet(
//             // style: GoogleFonts.caprasimo(
//             // style: GoogleFonts.mogra(
//             style: GoogleFonts.irishGrover(textStyle: TextStyles.splashText)),
//         Spacer(),
//         SpinKitFadingCircle(color: Colors.white, size: 50.0),
//         Spacer(),
//       ])));
// }

class HomePage extends StatefulWidget {
  HomePage({super.key});

  Report report = Report({});
  late Settings settings;

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) => setState(() => _adapterState = state));
  }

  @override
  void dispose() => super.dispose();

  Future<void> _loadData() async {
    readReport().then((savedReport) => widget.report.combine(savedReport));
    readSettings().then((settings) => widget.settings = settings);
  }

  @override
  Widget build(BuildContext context) => InAppNotification(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SafeArea(
              child: _adapterState == BluetoothAdapterState.on
                  ? ScannerView(widget.report, widget.settings)
                  : BluetoothOffView(adapterState: _adapterState)),
          theme: Themes.darkMode));
}
