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

  bool candidateHasShortAdvertisements(Device candidate) => true;

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

  (Device, double) matchScore(Device candidate, Device device) {
    final SortedList<Datum> deviceDatapoints = device.dataPoints();
    final SortedList<Datum> candidateDatapoints = candidate.dataPoints();

    final (double, double) averageRssiValues =
        (getAvgRssiValue(deviceDatapoints), getAvgRssiValue(candidateDatapoints));
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
    return (candidate, matchScore);
  }

  List<Device> findMatches(Report report, Device device) => report
      .devices()
      .difference({device})
      .where((candidate) => candidateTracesStartInWindow(candidate, device.dataPoints().last.time))
      .where(candidateHasShortAdvertisements)
      .map((candidate) => matchScore(candidate, device))
      .where((e) => e.$2 < Settings.shared.deTagTiveThresholdScore)
      .sorted((a, b) => a.$2.compareTo(b.$2))
      .map((e) => e.$1)
      .toList();

  void detagtive() =>
      report.devices().where(traceIsStrong).where(traceIsLong).where(traceEndedRecently).forEach((device) {
        final List<Device> matches = findMatches(report, device);

        if (matches.isNotEmpty) {
          final Device match = matches.first;
          report.data.remove(device.id);
          report.data[match.id]?.combine(device);
        }
      });
}
