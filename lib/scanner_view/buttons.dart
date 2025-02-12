part of 'package:bluetooth_detector/scanner_view/scanner_view.dart';

extension Buttons on ScannerViewState {
  Widget deleteReportButton() => FloatingActionButton.large(
      heroTag: "Delete Report",
      onPressed: () {
        widget.report = Report({});
        write(Report({}));
      },
      child: const Icon(Icons.delete));

  Widget shareButton() => FloatingActionButton.large(
      heroTag: "Share",
      onPressed: () {
        write(widget.report);
        shareReport();
      },
      child: const Icon(Icons.share));

  Widget reportViewerButton() => FloatingActionButton.large(
      heroTag: "Report Viewer Button",
      onPressed: () {
        Isolate.run(() => widget.report.refreshCache(widget.settings));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SafeArea(child: ReportView(widget.settings, report: widget.report))));
      },
      child: const Icon(Icons.newspaper));

  Widget scanButton() => FlutterBluePlus.isScanningNow
      ? FloatingActionButton.large(
          heroTag: "Stop Scanning Button",
          onPressed: () {
            stopScan();
            Isolate.run(() => widget.report.refreshCache(widget.settings));
            write(widget.report);
            if ((Platform.isAndroid || Platform.isIOS)) {
              Vibration.vibrate(
                  pattern: [250, 100, 100, 100, 100, 100, 250, 100, 500, 250, 250, 100, 750, 500],
                  intensities: [255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0]);
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SafeArea(child: ReportView(widget.settings, report: widget.report))));
          },
          child: const Icon(Icons.stop))
      : FloatingActionButton.large(
          heroTag: "Start Scanning Button", onPressed: () => startScan(), child: const Icon(Icons.play_arrow_rounded));

  Widget settingsButton() => FloatingActionButton.large(
      heroTag: "Settings Button",
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SafeArea(child: SettingsView(widget.settings)))),
      child: const Icon(Icons.settings));

  Widget notifyButton() => FloatingActionButton.large(
      heroTag: "Notify Button",
      onPressed: () => InAppNotification.show(
          context: context,
          child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colors.foreground),
              child: Center(
                  child:
                      Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: Text("Risky Devices Detected!"))),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SafeArea(child: ReportView(widget.settings, report: widget.report))))),
      child: const Icon(Icons.notifications));
}
