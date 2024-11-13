part of 'device.dart';

extension DeviceStats on Device {
  Set<Area> _areas(double thresholdDistance, Duration windowDuration) {
    Set<Area> result = {};
    locations(windowDuration).forEach((location) => result
        .where((area) => area.any((areaLocation) => distanceBetween(location, areaLocation) < thresholdDistance))
        .forEach((area) => area.add(location)));
    return result.combineSetsWithCommonElements();
  }

  double _distanceTravelled(Duration thresholdTime, Duration windowDuration) => paths(thresholdTime, windowDuration)
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);

  int _incidence(Duration thresholdTime, Duration windowDuration) =>
      this._timeClusterPrefix(thresholdTime, windowDuration).where((duration) => duration > thresholdTime).length + 1;

  Duration _timeTravelled(Duration thresholdTime, Duration windowDuration) => this
      ._timeClusterPrefix(thresholdTime, windowDuration)
      .where((duration) => duration < thresholdTime)
      .fold(Duration(), (a, b) => a + b);
}
