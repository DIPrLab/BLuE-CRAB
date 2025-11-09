import 'dart:math';
import 'package:blue_crab/extensions/date_time.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

/// Datum used to generate Data
@JsonSerializable()
class Datum {
  Datum(this.location, this._rssi, {DateTime? time}) {
    this.time = (time ?? DateTime.now()).roundedToSecond();
    _rssi = _rssi.map((e) => min(e, 0)).toList();
  }
  LatLng? location;
  List<int> _rssi;
  int rssi() => _rssi.average.round();
  List<int> rssiBackingData() => _rssi;
  late DateTime time;
}
