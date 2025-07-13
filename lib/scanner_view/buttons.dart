part of 'scanner_view.dart';

enum ButtonType {
  delete,
  load,
  notify,
  scan,
  settings,
  share,
  test,
  view,
}

class ButtonProps {
  ButtonProps(this.heroTag, this.icon, this.onPressed);

  String heroTag;
  IconData icon;
  void Function() onPressed;

  Widget toWidget() => Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton.large(heroTag: heroTag, onPressed: onPressed, child: Icon(icon))),
        Text(heroTag)
      ]);
}

extension Buttons on ScannerViewState {
  void runTests() => TestingSuite().testBleDoubtFiles();

  void deleteData() {
    report = Report({});
    write(Report({}));
  }

  void loadReportFromFile() => getReportFromFile().then((report) => this.report = report);

  void viewReport() {
    if (!updating) {
      report.refreshCache();
      write(report);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportView(report: report)));
  }

  void stopScanningAndViewReport() {
    stopScan();
    if (Platform.isAndroid || Platform.isIOS) {
      Vibration.vibrate(pattern: [100, 1], intensities: [255, 0]);
    }
    viewReport();
  }

  void viewSettings() =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => SafeArea(child: SettingsView(notify: notify))));

  void sendSampleNotification() => InAppNotification.show(
      context: context,
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colors.foreground),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Center(
              child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Risky Devices Detected!")))),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SafeArea(child: ReportView(report: report)))));

  Map<ButtonType, Widget> buttons() => [
        (ButtonType.delete, ButtonProps("Delete Data", Icons.delete, deleteData)),
        (ButtonType.load, ButtonProps("Load Sample Data", Icons.upload, loadReportFromFile)),
        (ButtonType.notify, ButtonProps("Notify", Icons.notifications, sendSampleNotification)),
        (
          ButtonType.scan,
          FlutterBluePlus.isScanningNow
              ? ButtonProps("Stop Scanning", Icons.stop_rounded, stopScanningAndViewReport)
              : ButtonProps("Start Scanning", Icons.play_arrow_rounded, startScan)
        ),
        (ButtonType.settings, ButtonProps("Settings", Icons.settings, viewSettings)),
        (ButtonType.share, ButtonProps("Share Report", Icons.share, () => shareReport(report))),
        (ButtonType.test, ButtonProps("Run Tests", Icons.science, runTests)),
        (ButtonType.view, ButtonProps("View Report", Icons.newspaper, viewReport)),
      ].toMap((e) => e.$1, (e) => e.$2.toWidget());
}
