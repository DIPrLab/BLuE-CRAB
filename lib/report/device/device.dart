import 'package:collection/collection.dart';
import 'package:latlng/latlng.dart';
import 'package:flutter/foundation.dart';
import 'package:blue_crab/report/datum.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/extensions/geolocator.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/assigned_numbers/company_identifiers.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/settings.dart';

part 'device_cache.dart';
part 'device_stats.dart';
part 'device.g.dart';

/// Device data type
///
/// This type is used to pair details of Bluetooth Devices
/// along with metadata that goes along with it
@JsonSerializable()
class Device {
  String id;
  String name;
  String platformName;
  List<int> manufacturer;
  Set<Datum> _dataPoints = {};
  bool isTrusted;
  DateTime lastUpdated = DateTime.now();

  late Duration timeTravelled;
  late int incidence;
  late Set<Area> areas;
  late double distanceTravelled;

  Device(this.id, this.name, this.platformName, this.manufacturer, {this.isTrusted = false, Set<Datum>? dataPoints}) {
    _dataPoints = dataPoints ?? {};
    updateStatistics();
  }
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  Set<Datum> dataPoints() => _dataPoints
      .where(
          (datum) => kDebugMode ? true : datum.time.isAfter(DateTime.now().subtract(Settings.shared.windowDuration())))
      .where((datum) => datum.location == null
          ? true
          : !Settings.shared.safeZones.any(
              (safeLocation) => distanceBetween(datum.location!, safeLocation) < Settings.shared.distanceThreshold()))
      .toSet();

  void addDatum(LatLng? location, int rssi) => addActualDatum(Datum(location, rssi));

  void addActualDatum(Datum datum) {
    lastUpdated = DateTime.now();
    _dataPoints.add(datum);
  }

  String deviceLabel() => !this.name.isEmpty
      ? this.name
      : !this.platformName.isEmpty
          ? this.platformName
          : !this.manufacturer.isEmpty
              ? this.manufacturers().join(", ")
              : this.id;

  Iterable<String> manufacturers() =>
      manufacturer.map((e) => company_identifiers[e.toRadixString(16).toUpperCase().padLeft(4, "0")] ?? "Unknown");

  Set<LatLng> locations() => this
      .dataPoints()
      .where((dataPoint) => dataPoint.location != null)
      .map((dataPoint) => dataPoint.location!)
      .toSet();

  List<Path> paths() {
    List<Path> paths = <Path>[];
    List<PathComponent> dataPoints = this
        .dataPoints()
        .where((dataPoint) => dataPoint.location != null)
        .map((datum) => PathComponent(datum.time, datum.location!))
        .sorted((a, b) => a.time.compareTo(b.time));

    while (!dataPoints.isEmpty) {
      PathComponent curr = dataPoints.first;
      dataPoints.removeAt(0);
      DateTime time1 = paths.isEmpty ? DateTime(1970) : paths.last.last.time;
      DateTime time2 = curr.time;
      Duration time = time2.difference(time1);
      if (time < Settings.shared.timeThreshold()) {
        paths.last.add(curr);
      } else {
        paths.add([curr]);
      }
    }

    return paths;
  }

  Device combine(Device device) {
    lastUpdated = DateTime.now();
    _dataPoints.addAll(device._dataPoints);
    return this;
  }
}
