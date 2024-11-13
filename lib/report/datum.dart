import 'package:latlng/latlng.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:statistics/statistics.dart';

part 'datum.g.dart';

/// Datum used to generate Data
@JsonSerializable()
class Datum {
  LatLng? location;
  int rssi;
  DateTime time = DateTime.now();

  Datum(this.location, this.rssi);
  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);
  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
