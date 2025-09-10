part of 'scanner_view.dart';

extension DeTagTive on ScannerViewState {
  void detagtive() {
    report
        .devices()
        .where((e) => e.dataPoints().map((e) => e.rssi).average < Settings.shared.deTagTiveRssiThreshold)
        .where((e) =>
            e
                .dataPoints()
                .map((e) => e.time)
                .sorted((a, b) => a.compareTo(b))
                .last
                .difference(e.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first) >
            Settings.shared.deTagTiveMinLength)
        .where((e) {
      // traces that end
      return true;
    }).forEach((e) {
      // DeTagTive
    });
  }
}
