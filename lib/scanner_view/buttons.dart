part of 'scanner_view.dart';

extension Buttons on ScannerViewState {
  Widget testButton() => FloatingActionButton.large(
      heroTag: "Test Report",
      onPressed: () {
        TestingSuite().testBleDoubtFiles();
      },
      child: const Icon(Icons.science));

  Widget deleteReportButton() => FloatingActionButton.large(
      heroTag: "Delete Report",
      onPressed: () {
        report = Report({});
        write(Report({}));
      },
      child: const Icon(Icons.delete));

  Widget loadReportButton() => FloatingActionButton.large(
      heroTag: "Load Sample Report",
      onPressed: () {
        readReport().then((report) {
          report.combine(report);
          write(report);
        });
      },
      child: const Icon(Icons.upload));

  Widget shareButton() => FloatingActionButton.large(
      heroTag: "Share", onPressed: () => write(report).then((_) => shareReport()), child: const Icon(Icons.share));

  Widget reportViewerButton() => FloatingActionButton.large(
      heroTag: "Report Viewer Button",
      onPressed: () {
        if (!updating) {
          report.refreshCache();
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => SafeArea(child: ReportView(report: report))));
      },
      child: const Icon(Icons.newspaper));

  Widget scanButton() => FlutterBluePlus.isScanningNow
      ? FloatingActionButton.large(
          heroTag: "Stop Scanning Button",
          onPressed: () {
            stopScan().then((_) => write(report));
            if (!updating) {
              report.refreshCache();
            }
            if (Platform.isAndroid || Platform.isIOS) {
              Vibration.vibrate(pattern: [100, 1], intensities: [255, 0]);
            }
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SafeArea(child: ReportView(report: report))));
          },
          child: const Icon(Icons.stop))
      : FloatingActionButton.large(
          heroTag: "Start Scanning Button", onPressed: startScan, child: const Icon(Icons.play_arrow_rounded));

  Widget settingsButton(VoidCallback notify) => FloatingActionButton.large(
      heroTag: "Settings Button",
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SafeArea(child: SettingsView(notify: notify)))),
      child: const Icon(Icons.settings));

  Widget notifyButton() => FloatingActionButton.large(
      heroTag: "Notify Button",
      onPressed: () => InAppNotification.show(
          context: context,
          child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colors.foreground),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Center(
                  child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Risky Devices Detected!")))),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => SafeArea(child: ReportView(report: report))))),
      child: const Icon(Icons.notifications));
}
