import 'package:latlng/latlng.dart';
import 'package:bluetooth_detector/report/device/device.dart';
import 'package:bluetooth_detector/report/datum.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/ble_doubt_report/ble_doubt_device.dart';
import 'package:bluetooth_detector/ble_doubt_report/ble_doubt_detection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ble_doubt_report.g.dart';

@JsonSerializable()
class BleDoubtReport {
  List<BleDoubtDevice> devices;
  List<BleDoubtDetection> detections;

  Report toReport() {
    Report report = Report({});

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

  BleDoubtReport(this.devices, this.detections);
  factory BleDoubtReport.fromJson(Map<String, dynamic> json) => _$BleDoubtReportFromJson(json);
  Map<String, dynamic> toJson() => _$BleDoubtReportToJson(this);
}
