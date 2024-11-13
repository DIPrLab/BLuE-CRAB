part of 'device.dart';

extension DeviceCache on Device {
  void updateStatistics(Settings settings) {
    areas = _areas(settings.distanceThreshold(), settings.windowDuration());
    distanceTravelled = _distanceTravelled(settings.timeThreshold(), settings.windowDuration());
    incidence = _incidence(settings.timeThreshold(), settings.windowDuration());
    timeTravelled = _timeTravelled(settings.timeThreshold(), settings.windowDuration());
  }

  List<Duration> _timeClusterPrefix(Duration thresholdTime, Duration windowDuration) => this
      .dataPoints(windowDuration)
      .map((datum) => datum.time)
      .sorted()
      .mapOrderedPairs((pair) => pair.$2.difference(pair.$1))
      .toList();
}
