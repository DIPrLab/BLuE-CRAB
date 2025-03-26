import 'package:json_annotation/json_annotation.dart';

part 'ble_doubt_detection.g.dart';

@JsonSerializable()
class BleDoubtDetection {
  BleDoubtDetection(this.lat, this.long, this.mac, this.rssi, this.t);
  factory BleDoubtDetection.fromJson(Map<String, dynamic> json) => _$BleDoubtDetectionFromJson(json);

  double lat;
  double long;
  String mac;
  int rssi;
  DateTime t;
  Map<String, dynamic> toJson() => _$BleDoubtDetectionToJson(this);
}
