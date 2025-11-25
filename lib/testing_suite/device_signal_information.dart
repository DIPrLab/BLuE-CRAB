part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension DeviceSignalInformation on TestingSuite {
  CSVData getDeviceSignalInformation(Device device) {
    final CSVData csv = CSVData([
      "TIME_SINCE_INITIAL_DETECTION",
      "RSSI",
      "SMOOTHED_EMA",
      "SMOOTHED_MA_PADDING",
      "SMOOTHED_MA_RESIZED",
      "DISTANCE_FROM_USER",
    ]);
    final List<num> rssiValues = device.dataPoints().map((e) => e.rssi()).toList();
    final List<num> smoothEMA = rssiValues.smoothedByExponentiallyWeightedMovingAverage(0.7);
    final List<num> smoothMAPadding = rssiValues.smoothedByMovingAverage(5, SmoothingMethod.padding);
    final List<num> smoothMAResizing = rssiValues.smoothedByMovingAverage(3, SmoothingMethod.resizing);
    device.dataPoints().indexed.forEach((e) => csv.addRow([
          e.$2.time.difference(device.dataPoints().first.time).inSeconds,
          e.$2.rssi(),
          smoothEMA[e.$1],
          smoothMAPadding[e.$1],
          smoothMAResizing[e.$1],
          device.proximity()
        ].map((e) => e.toString()).toList()));
    return csv;
  }
}
