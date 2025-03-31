import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';
import 'package:statistics/statistics.dart';

part 'datum.g.dart';

/// Datum used to generate Data
@JsonSerializable()
class Datum {
  Datum(this.location, this.rssi) {
    final DateTime now = DateTime.now();
    time = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  }
  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);
  LatLng? location;
  int rssi;
  late DateTime time;
  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
