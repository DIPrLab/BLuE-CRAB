import 'package:blue_crab/assigned_numbers/company_identifiers.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/extensions/geolocator.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/report/datum.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

part 'device.g.dart';
part 'device_cache.dart';
part 'device_stats.dart';

/// Device data type
///
/// This type is used to pair details of Bluetooth Devices
/// along with metadata that goes along with it
@JsonSerializable()
class Device {
  Device(this.id, this.name, this.platformName, this.manufacturer, {this.isTrusted = false, Set<Datum>? dataPoints}) {
    _dataPoints = dataPoints ?? {};
    updateStatistics();
  }
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
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
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  Set<Datum> dataPoints({bool testing = false}) => _dataPoints
      .where((datum) =>
          kDebugMode || testing ? true : datum.time.isAfter(DateTime.now().subtract(Settings.shared.windowDuration())))
      .where((datum) => datum.location == null
          ? true
          : !Settings.shared.safeZones.any(
              (safeLocation) => distanceBetween(datum.location!, safeLocation) < Settings.shared.distanceThreshold()))
      .toSet();

  void addDatum(LatLng? location, int rssi) {
    lastUpdated = DateTime.now();
    final DateTime now = lastUpdated;
    final Duration difference = _dataPoints.isEmpty
        ? Duration.zero
        : DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second)
            .difference(_dataPoints.map((dp) => dp.time).sorted((a, b) => a.compareTo(b)).last);
    if (_dataPoints.isEmpty || difference > const Duration(seconds: 10)) {
      _dataPoints.add(Datum(location, rssi));
    }
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

  List<Path> paths() {
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

  Device combine(Device device) {
    lastUpdated = DateTime.now();
    _dataPoints.addAll(device._dataPoints);
    return this;
  }
}
