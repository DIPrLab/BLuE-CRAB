part of 'scanner_view.dart';

extension DeTagTive on ScannerViewState {
  bool traceIsStrong(Device device) =>
      device.dataPoints().map((e) => e.rssi).average > Settings.shared.deTagTiveRssiThreshold;

  bool traceIsLong(Device device) =>
      device.dataPoints().last.time.difference(device.dataPoints().first.time) > Settings.shared.deTagTiveMinLength;

  bool traceEndedRecently(Device device) =>
      DateTime.now().difference(device.dataPoints().last.time) < Settings.shared.deTagTiveEndThreshold;

  bool candidateTracesStartInWindow(Device candidate, DateTime deviceEnd) {
    const Duration window = Duration.zero;
    final DateTime candidateStart = candidate.dataPoints().first.time;
    return deviceEnd == candidateStart || deviceEnd.isBefore(candidateStart);
  }

  bool candidateHasShortAdvertisements(Device candidate) =>
      candidate
          .dataPoints()
          .map((e) => e.time)
          .toList()
          .mapOrderedPairs((e) => e.$2.difference(e.$1).inSeconds)
          .average <
      Settings.shared.deTagTiveMaxAvgAdvertisementInterval.inSeconds;

  double getAvgRssiValue(SortedList<Datum> datapoints) {
    double result = 0;
    try {
      result = datapoints.map((e) => e.rssi).average;
    } catch (e) {
      Logger().e("Error calculating avg rssi value: $e");
    }
    return result;
  }

  double getStdDevOfRssiValues(SortedList<Datum> datapoints) {
    double result = 0;
    try {
      result = datapoints.map((e) => e.rssi).standardDeviation;
    } catch (e) {
      Logger().e("Error calculating std dev of rssi values: $e");
    }
    return result;
  }

  double getAvgTransmissionIntervalInSeconds(SortedList<Datum> datapoints) {
    double result = 0;
    try {
      result = datapoints.orderedPairs().map((e) => e.$2.time.difference(e.$1.time).inSeconds).average;
    } catch (e) {
      Logger().e("Error calculating avg transmission interval: $e");
    }
    return result;
  }

  double matchScore(Device candidate, Device device, double shift) {
    final SortedList<Datum> deviceDatapoints = device.dataPoints();
    final SortedList<Datum> candidateDatapoints = candidate.dataPoints();

    final (double, double) averageRssiValues =
        (getAvgRssiValue(deviceDatapoints) + shift, getAvgRssiValue(candidateDatapoints));
    final (double, double) stdDevOfRssiValues =
        (getStdDevOfRssiValues(deviceDatapoints), getStdDevOfRssiValues(candidateDatapoints));
    final (double, double) averageTransmissionDurationInSeconds = (
      getAvgTransmissionIntervalInSeconds(deviceDatapoints),
      getAvgTransmissionIntervalInSeconds(candidateDatapoints)
    );

    final double matchScore = [
      averageRssiValues,
      stdDevOfRssiValues,
      averageTransmissionDurationInSeconds,
    ].map((e) => (e.$1 - e.$2).abs()).fold(0, (acc, curr) => acc + curr);
    return matchScore;
  }

  double getShift(DateTime t) {
    final (List<int>, List<int>) rssi = report
        .devices()
        .where((d) => d.dataPoints().any((e) => e.time.isBefore(t)))
        .where((d) => d.dataPoints().any((e) => e.time.isAfter(t)))
        .map((d) => (d.dataPoints().where((e) => e.time.isBefore(t)), d.dataPoints().where((e) => e.time.isAfter(t))))
        .map((e) => (e.$1.map((datum) => datum.rssi).toList(), e.$2.map((datum) => datum.rssi).toList()))
        .fold((List<int>.empty(growable: true), List<int>.empty(growable: true)),
            (acc, curr) => (acc.$1 + curr.$1, acc.$2 + curr.$2));
    return rssi.$2.average - rssi.$1.average;
  }

  Device? findMatch(Report report, Device device) => report
      .devices()
      .difference({device})
      .where((candidate) => candidateTracesStartInWindow(candidate, device.dataPoints().last.time))
      .where(candidateHasShortAdvertisements)
      .map((candidate) => (candidate, matchScore(candidate, device, getShift(device.dataPoints().last.time))))
      .where((e) => e.$2 < Settings.shared.deTagTiveThresholdScore)
      .sorted((a, b) => a.$2.compareTo(b.$2))
      .first
      .$1;

  void detagtive() =>
      report.devices().where(traceIsStrong).where(traceIsLong).where(traceEndedRecently).forEach((device) {
        final Device? match = findMatch(report, device);

        if (match != null) {
          report.data.remove(device.id);
          report.data[match.id]?.combine(device);
        }
      });
}
