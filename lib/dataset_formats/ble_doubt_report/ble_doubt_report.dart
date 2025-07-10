import 'package:blue_crab/dataset_formats/ble_doubt_report/ble_doubt_detection.dart';
import 'package:blue_crab/dataset_formats/ble_doubt_report/ble_doubt_device.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/device/device.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlng/latlng.dart';

part 'ble_doubt_report.g.dart';

@JsonSerializable()
class BleDoubtReport {
  BleDoubtReport(this.devices, this.detections);
  factory BleDoubtReport.fromJson(Map<String, dynamic> json) => _$BleDoubtReportFromJson(json);

  List<BleDoubtDevice> devices;
  List<BleDoubtDetection> detections;

  Report toReport() {
    final Report report = Report({});

    devices.forEach((device) {
      report.addDevice(Device(device.address, device.name, "", [device.manufacturer],
          dataPoints: detections
              .where((detection) => detection.mac == device.address)
              .map((detection) =>
                  Datum(LatLng.degree(detection.lat, detection.long), detection.rssi)..time = detection.t)
              .toSet()));
    });

    return report;
  }

  Map<String, dynamic> toJson() => _$BleDoubtReportToJson(this);
}
