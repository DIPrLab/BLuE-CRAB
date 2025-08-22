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
    final List<num> smoothEMA =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByExponentiallyWeightedMovingAverage(0.7);
    final List<num> smoothMAPadding =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByMovingAverage(5, SmoothingMethod.padding);
    final List<num> smoothMAResizing =
        device.dataPoints().map((e) => e.rssi).toList().smoothedByMovingAverage(3, SmoothingMethod.resizing);
    device.dataPoints().indexed.toList().forEach((e) => csv.addRow([
          e.$2.time.difference(device.dataPoints().first.time).inSeconds,
          e.$2.rssi,
          smoothEMA[e.$1],
          smoothMAPadding[e.$1],
          smoothMAResizing[e.$1],
          device.distance()
        ].map((e) => e.toString()).toList()));
    return csv;
  }
}
