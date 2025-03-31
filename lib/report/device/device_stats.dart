part of 'device.dart';

extension DeviceStats on Device {
  Set<Area> _areas() {
    final Set<Area> result = {};
    locations().forEach((location) {
      if (result
          .where((area) =>
              area.any((areaLocation) => distanceBetween(location, areaLocation) < Settings.shared.distanceThreshold()))
          .isEmpty) {
        result.add({location});
      } else {
        result
            .where((area) => area
                .any((areaLocation) => distanceBetween(location, areaLocation) < Settings.shared.distanceThreshold()))
            .forEach((a) => a.add(location));
      }
    });
    return result.combineSetsWithCommonElements();
  }

  double _distanceTravelled() => paths()
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.0, (a, b) => a + b))
      .fold(0.0, (a, b) => a + b);

  int _incidence() => _timeClusterPrefix().where((duration) => duration > Settings.shared.timeThreshold()).length + 1;

  Duration _timeTravelled() => _timeClusterPrefix()
      .where((duration) => duration <= Settings.shared.timeThreshold())
      .fold(Duration.zero, (a, b) => a + b);
}
