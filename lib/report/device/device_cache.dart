part of 'device.dart';

extension Cache on Device {
  void updateStatistics(Settings settings) {
    areas = _areas(settings.distanceThreshold(), settings.windowDuration());
    distanceTravelled = _distanceTravelled(settings.timeThreshold(), settings.windowDuration());
    incidence = _incidence(settings.timeThreshold(), settings.windowDuration());
    timeTravelled = _timeTravelled(settings.timeThreshold(), settings.windowDuration());
  }

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
      this
          .dataPoints(windowDuration)
          .map((datum) => datum.time)
          .sorted((a, b) => a.compareTo(b))
          .orderedPairs()
          .map((pair) => pair.$2.difference(pair.$1))
          .where((duration) => duration > thresholdTime)
          .length +
      1;

  Duration _timeTravelled(Duration thresholdTime, Duration windowDuration) => this
      .dataPoints(windowDuration)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .where((duration) => duration < thresholdTime)
      .fold(Duration(), (a, b) => a + b);
}
