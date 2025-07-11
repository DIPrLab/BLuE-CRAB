part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension RssiMetricData on TestingSuite {
  String getRssiMetricData(Report report, Set<String> gt, int factor) {
    final Iterable<List<num>> rssiPrefix = report
        .devices()
        .map((device) => device.dataPoints())
        .map((e) => e.map((datum) => datum.rssi))
        .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding));
    final Iterable<double> rssiAverages = rssiPrefix.map((e) => e.average);
    final Iterable<num> rssiStdDevs = rssiPrefix.map((e) => e.standardDeviation());

    return [
      ("AVERAGE_AVERAGE", rssiAverages.average),
      ("MEDIAN_AVERAGE", rssiAverages.median()),
      ("MIN_AVERAGE", rssiAverages.min),
      ("MAX_AVERAGE", rssiAverages.max),
      ("AVERAGE_STD_DEV", rssiStdDevs.average),
      ("MEDIAN_STD_DEV", rssiStdDevs.median()),
      ("MIN_STD_DEV", rssiStdDevs.min),
      ("MAX_STD_DEV", rssiStdDevs.max),
      ("AVERAGE_STD_DEV_SUSPICIOUS", rssiStdDevs.average),
      ("MEDIAN_STD_DEV_SUSPICIOUS", rssiStdDevs.median()),
      ("MIN_STD_DEV_SUSPICIOUS", rssiStdDevs.min),
      ("MAX_STD_DEV_SUSPICIOUS", rssiStdDevs.max),
      ("AVERAGE_STD_DEV_NOT_SUSPICIOUS", rssiStdDevs.average),
      ("MEDIAN_STD_DEV_NOT_SUSPICIOUS", rssiStdDevs.median()),
      ("MIN_STD_DEV_NOT_SUSPICIOUS", rssiStdDevs.min),
      ("MAX_STD_DEV_NOT_SUSPICIOUS", rssiStdDevs.max),
    ].map((e) => "${e.$1.padRight(30)} : ${e.$2}").join("\n");
  }
}
