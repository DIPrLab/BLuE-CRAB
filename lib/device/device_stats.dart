part of 'device.dart';

extension DeviceStats on Device {
  void updateStatistics() => [
        () => distanceTravelled = _distanceTravelled(),
        () => timeTravelled = _timeTravelled(),
        () => incidence = _incidence(),
      ].forEach((f) => f());

  List<Duration> _timeClusterPrefix() => dataPoints()
      .map((datum) => datum.time)
      .sorted()
      .fold(
          List<(DateTime, DateTime)>.empty(),
          (acc, curr) => acc.isEmpty
              ? [(curr, curr)]
              : curr.difference(acc.last.$2) > Settings.shared.timeThreshold()
                  ? acc + [(curr, curr)]
                  : (acc..last = (acc.last.$1, curr)))
      .map((pair) => pair.$2.difference(pair.$1))
      .toList();

  double _distanceTravelled() => paths()
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.toDouble(), (a, b) => a + b))
      .fold(0.toDouble(), (a, b) => a + b);

  int _incidence() => _timeClusterPrefix().length;

  Duration _timeTravelled() => _timeClusterPrefix().fold(Duration.zero, (a, b) => a + b);

  num distance() {
    const num measuredPower = -59;
    final num rssi = dataPoints()
        .sorted((a, b) => a.time.compareTo(b.time))
        .map((e) => e.rssi)
        .toList()
        .smoothedByMovingAverage(5, SmoothingMethod.resizing)
        .last;
    const n = 2;
    return pow(10, (measuredPower - rssi) / (10 * n));
  }
}
