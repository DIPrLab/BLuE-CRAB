part of 'device.dart';

extension DeviceStats on Device {
  double _distanceTravelled() => paths()
      .map((path) => path
          .mapOrderedPairs((pair) => distanceBetween(pair.$1.location, pair.$2.location))
          .fold(0.toDouble(), (a, b) => a + b))
      .fold(0.toDouble(), (a, b) => a + b);

  int _incidence() => _timeClusterPrefix().where((duration) => duration > Settings.shared.timeThreshold()).length + 1;

  Duration _timeTravelled() => _timeClusterPrefix()
      .where((duration) => duration <= Settings.shared.timeThreshold())
      .fold(Duration.zero, (a, b) => a + b);
}
