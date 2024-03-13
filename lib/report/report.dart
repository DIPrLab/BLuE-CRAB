import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';

typedef Report = Map<DeviceIdentifier, Device?>;

class ReportData {
  // DateTime time = DateTime.now();
  List<DataPoint> dataPoints = [];

  Report generateReport() {
    Report report = Report();
    Set<Device> devices = _getDevices();

    for (Device device in devices) {
      report[device.device.remoteId] = device;
    }

    return report;
  }

  Set<Device> _getDevices() {
    Set<Device> devices = <Device>{};
    for (var dataPoint in dataPoints) {
      for (var device in dataPoint.devices) {
        devices.add(Device(device.device, device.advertisementData));
      }
    }
    return devices;
  }
}

class DataPoint {
  Position location;
  List<ScanResult> devices;
  DateTime time = DateTime.now();
  DataPoint(this.location, this.devices);
}

class Device {
  BluetoothDevice device;
  AdvertisementData data;
  late Set<LatLng> locations;
  Device(this.device, this.data);
}
