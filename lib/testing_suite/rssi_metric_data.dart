part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension RssiMetricData on TestingSuite {
  String getRssiMetricData(Report report, Set<String> gt, int factor) => [
        (
          "AVERAGE_AVERAGE",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.average)
              .average
        ),
        (
          "MEDIAN_AVERAGE",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.average)
              .median()
        ),
        (
          "MIN_AVERAGE",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.average)
              .min
        ),
        (
          "MAX_AVERAGE",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.average)
              .max
        ),
        (
          "AVERAGE_STD_DEV",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .average
        ),
        (
          "MEDIAN_STD_DEV",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .median()
        ),
        (
          "MIN_STD_DEV",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .min
        ),
        (
          "MAX_STD_DEV",
          report
              .devices()
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .max
        ),
        (
          "AVERAGE_STD_DEV_SUSPICIOUS",
          report
              .devices()
              .where((device) => gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .average
        ),
        (
          "MEDIAN_STD_DEV_SUSPICIOUS",
          report
              .devices()
              .where((device) => gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .median()
        ),
        (
          "MIN_STD_DEV_SUSPICIOUS",
          report
              .devices()
              .where((device) => gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .min
        ),
        (
          "MAX_STD_DEV_SUSPICIOUS",
          report
              .devices()
              .where((device) => gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .max
        ),
        (
          "AVERAGE_STD_DEV_NOT_SUSPICIOUS",
          report
              .devices()
              .where((device) => !gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .average
        ),
        (
          "MEDIAN_STD_DEV_NOT_SUSPICIOUS",
          report
              .devices()
              .where((device) => !gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .median()
        ),
        (
          "MIN_STD_DEV_NOT_SUSPICIOUS",
          report
              .devices()
              .where((device) => !gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .min
        ),
        (
          "MAX_STD_DEV_NOT_SUSPICIOUS",
          report
              .devices()
              .where((device) => !gt.contains(device.id))
              .map((device) => device.dataPoints())
              .map((e) => e.map((datum) => datum.rssi))
              .map((e) => e.toList().smoothedByMovingAverage(factor, SmoothingMethod.padding))
              .map((e) => e.standardDeviation())
              .max
        ),
      ].map((e) => "${e.$1.padRight(30)} : ${e.$2}").join("\n");
}
