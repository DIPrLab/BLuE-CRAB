import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/device/device.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';
import 'package:sqflite/sqflite.dart';
import 'package:statistics/statistics.dart';

part 'compact_dataset.g.dart';

@JsonSerializable()
class CompactDataset {
  CompactDataset(this.devices, this.locationHistory);
  factory CompactDataset.fromJson(Map<String, dynamic> json) => _$CompactDatasetFromJson(json);
  Map<String, dynamic> toJson() => _$CompactDatasetToJson(this);

  Map<String, (String, String, List<int>, Map<DateTime, List<int>>, int?)> devices;
  Map<DateTime, (double, double)?> locationHistory;

  LatLng? toLatLng((double, double)? location) => location == null ? null : LatLng.degree(location.$1, location.$2);
  LatLng? getLocationAtTime(DateTime t) => toLatLng(locationHistory.entries
      .where((e) => e.key.isBefore(t) || e.key == t)
      .sorted((a, b) => a.key.compareTo(b.key))
      .last
      .value);

  Report toReport() => Report(devices.entries
      .map((e) => MapEntry(
          e.key,
          Device(e.key, e.value.$1, e.value.$2, e.value.$3,
              dataPoints: e.value.$4.entries
                  .map((e) => Datum(getLocationAtTime(e.key), e.value, time: e.key))
                  .map((e) => MapEntry(e.time, e))
                  .toMap((e) => e.key, (e) => e.value))))
      .toMap((e) => e.key, (e) => e.value));

  Future<Database> toDB() async {
    final Database db = await openDatabase(
      'my_db.db',
      onOpen: (db) async {
        await db.execute(
            "create table Devices (id text not null, name text not null, platform text not null, manufacturer text, t integer)");
        await db.execute("create table ScanData (device_id text not null, time text not null, rssi integer not null)");
        await db.execute("create table LocationHistory (time text not null, latitude integer, longitude integer)");
      },
    );

    devices.entries.forEach((device) {
      final deviceEntry = {
        "id": device.key,
        "name": device.value.$1,
        "platform": device.value.$2,
        "manufacturer": device.value.$3.toString(),
        "t": device.value.$5,
      };
      db.insert("Devices", deviceEntry, conflictAlgorithm: ConflictAlgorithm.replace);

      device.value.$4.entries.forEach((entry) {
        final scanEntry = {"device_id": device.key, "time": entry.key.toIso8601String(), "rssi": entry.value[0]};
        db.insert("ScanData", scanEntry, conflictAlgorithm: ConflictAlgorithm.replace);
      });
    });

    locationHistory.entries.forEach((entry) {
      final locationEntry = {
        "time": entry.key.toIso8601String(),
        "latitude": entry.value?.$1,
        "longitude": entry.value?.$2
      };
      db.insert("LocationHistory", locationEntry, conflictAlgorithm: ConflictAlgorithm.replace);
    });

    await db.close();

    return db;
  }
}
