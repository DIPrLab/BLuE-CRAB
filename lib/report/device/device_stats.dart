part of 'device.dart';

extension DeviceStats on Device {
  Set<Area> _areas(Settings settings) {
    Set<Area> result = {};
    locations(settings).forEach((location) => result
        .where((area) =>
            area.any((areaLocation) => distanceBetween(location, areaLocation) < settings.distanceThreshold()))
        .forEach((area) => area.add(location)));
    return result.combineSetsWithCommonElements();
  }

  double _distanceTravelled(Settings settings) => paths(settings)
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);

  int _incidence(Settings settings) =>
      this._timeClusterPrefix(settings).where((duration) => duration > settings.timeThreshold()).length + 1;

  Duration _timeTravelled(Settings settings) => this
      ._timeClusterPrefix(settings)
      .where((duration) => duration <= settings.timeThreshold())
      .fold(Duration(), (a, b) => a + b);
}
