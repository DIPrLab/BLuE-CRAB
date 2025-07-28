import 'package:blue_crab/assigned_numbers/company_identifiers.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/extensions/geolocator.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/settings.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

part 'device_stats.dart';

/// Device data type
///
/// This type is used to pair details of Bluetooth Devices
/// along with metadata that goes along with it
@JsonSerializable()
class Device {
  Device(this.id, this.name, this.platformName, this.manufacturer, {this.t, Map<DateTime, Datum>? dataPoints}) {
    _dataPoints = dataPoints ?? Map.identity();
    updateStatistics();
  }
  String id;
  String name;
  String platformName;
  int? t;
  List<int> manufacturer;
  Map<DateTime, Datum> _dataPoints = {};
  DateTime lastUpdated = DateTime.now();

  late Duration timeTravelled;
  late int incidence;
  late double distanceTravelled;

  Set<Datum> dataPoints({bool testing = false}) => _dataPoints.values
      .where((datum) =>
          datum.location == null ||
          !Settings.shared.safeZones.any(
              (safeLocation) => distanceBetween(datum.location!, safeLocation) < Settings.shared.distanceThreshold()))
      .toSet();

  void addDatum(LatLng? location, int rssi) {
    lastUpdated = DateTime.now();
    final Datum d = Datum(location, rssi);
    _dataPoints.update(d.time, (e) => e..rssi = rssi, ifAbsent: () => d);
  }

  String deviceLabel() => name.isNotEmpty
      ? name
      : platformName.isNotEmpty
          ? platformName
          : manufacturer.isNotEmpty
              ? manufacturers().join(", ")
              : id;

  Iterable<String> manufacturers() =>
      manufacturer.map((e) => companyIdentifiers[e.toRadixString(16).toUpperCase().padLeft(4, "0")] ?? "Unknown");

  Set<LatLng> locations() =>
      dataPoints().where((dataPoint) => dataPoint.location != null).map((dataPoint) => dataPoint.location!).toSet();

  List<Path> paths2() {
    final List<Path> paths = <Path>[];
    final List<PathComponent> dataPoints = this
        .dataPoints()
        .where((dataPoint) => dataPoint.location != null)
        .map((datum) => PathComponent(datum.time, datum.location!))
        .sorted((a, b) => a.time.compareTo(b.time));

    while (dataPoints.isNotEmpty) {
      final PathComponent curr = dataPoints.first;
      dataPoints.removeAt(0);
      final DateTime time1 = paths.isEmpty ? DateTime(1970) : paths.last.last.time;
      final DateTime time2 = curr.time;
      final Duration time = time2.difference(time1);
      if (time < Settings.shared.timeThreshold()) {
        paths.last.add(curr);
      } else {
        paths.add([curr]);
      }
    }

    return paths;
  }

  List<Path> paths() => dataPoints()
          .where((dataPoint) => dataPoint.location != null)
          .map((datum) => PathComponent(datum.time, datum.location!))
          .sorted((a, b) => a.time.compareTo(b.time))
          .fold<List<Path>>([], (paths, curr) {
        if (paths.isEmpty || curr.time.difference(paths.last.last.time) >= Settings.shared.timeThreshold()) {
          return [
            ...paths,
            [curr]
          ];
        } else {
          final updatedLast = [...paths.last, curr];
          return [...paths.take(paths.length - 1), updatedLast];
        }
      });

  Device combine(Device device) {
    lastUpdated = DateTime.now();
    _dataPoints.addAll(device._dataPoints);
    return this;
  }
}
