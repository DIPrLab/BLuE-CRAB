part of 'package:bluetooth_detector/scanner_view/scanner_view.dart';

extension Buttons on ScannerViewState {
  Widget reportViewerButton() => FloatingActionButton.large(
      onPressed: () {
        log();
        widget.report.refreshCache(widget.settings);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SafeArea(child: ReportView(widget.settings, report: widget.report))));
      },
      child: const Icon(Icons.newspaper));

  Widget scanButton() => FlutterBluePlus.isScanningNow
      ? FloatingActionButton.large(
          onPressed: () {
            log();
            stopScan();
            write(widget.report);
            Vibration.vibrate(
                pattern: [250, 100, 100, 100, 100, 100, 250, 100, 500, 250, 250, 100, 750, 500],
                intensities: [255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0]);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SafeArea(child: ReportView(widget.settings, report: widget.report))));
          },
          child: const Icon(Icons.stop))
      : FloatingActionButton.large(onPressed: () => startScan(), child: const Icon(Icons.play_arrow_rounded));

  Widget settingsButton() => FloatingActionButton.large(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SafeArea(child: SettingsView(widget.settings)))),
      child: const Icon(Icons.settings));
}
