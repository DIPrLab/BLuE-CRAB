import 'package:json_annotation/json_annotation.dart';

part 'ble_doubt_detection.g.dart';

@JsonSerializable()
class BleDoubtDetection {
  double lat;
  double long;
  String mac;
  int rssi;
  DateTime t;

  BleDoubtDetection(this.lat, this.long, this.mac, this.rssi, this.t);
  factory BleDoubtDetection.fromJson(Map<String, dynamic> json) => _$BleDoubtDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$BleDoubtDetectionToJson(this);
}
