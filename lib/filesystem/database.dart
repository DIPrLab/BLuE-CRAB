import 'dart:io';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/device/device.dart';
import 'package:latlng/latlng.dart';
import 'package:sqflite/sqflite.dart';

class ReportDatabase {
  ReportDatabase() {
    initDatabase();
  }

  String deviceDetails = "device_details";
  String deviceTimes = "device_times";
  String locations = "locations";

  Database? source;

  void addDevice(Device d) {
    source?.insert(
        deviceDetails,
        Map.from({
          "id": d.id,
          "name": d.name,
          "platform_name": d.platformName,
          "manufacturer_ids": d.manufacturer,
          "t": d.t
        }));
  }

  void addDeviceTime(Device d, Datum dt) {
    source?.insert(deviceDetails, Map.from({"id": d.id, "time": dt.time.toIso8601String(), "rssi": dt.rssi}));
  }

  void addLocation(DateTime t, LatLng location) {
    source?.insert(locations,
        Map.from({"time": t.toIso8601String(), "latitude": location.latitude, "longitude": location.longitude}));
  }

  void initDatabase() {
    getDatabasesPath().then((dir) {
      final Directory dbDir = Directory(dir);
      final File dbFile = File("${dbDir.path}/database.db");
      openDatabase(dbFile.path, onCreate: createSchema).then((db) {
        source = db;
      });
    });
  }

  void createSchema(Database db, int version) {}
}
