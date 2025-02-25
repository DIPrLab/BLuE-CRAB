import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';

class TestingSuite {
  Report report;
  Set<Device> flaggedDevices = {};

  TestingSuite(this.report);

  List<DateTime> getTimestamps() {
    Set<DateTime> timestampSet = report
        .devices()
        .map((d) => d.dataPoints(testing: true).map((d) => d.time).toSet())
        .fold({}, (a, b) => b..addAll(a));

    return timestampSet.toList()..sort();
  }

  void test() {
    Set<Device> devices = report.devices().where((d) => !d.dataPoints(testing: true).isEmpty).toSet();
    List<DateTime> timestamps = getTimestamps();
    DateTime currentTime = timestamps.first;
    while (!devices.isEmpty) {
      devices = devices.where((d) => !d.dataPoints(testing: true).isEmpty).toSet();
    }
  }
}
