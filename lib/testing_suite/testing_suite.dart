import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report/datum.dart';
import 'package:blue_crab/settings.dart';

class TestingSuite {
  final Report report;
  Set<Device> flaggedDevices = {};
  Map<DateTime, Set<Device>> flaggedDevicesWithTimeStamps = {};
  late List<DateTime> timeStamps;

  TestingSuite(this.report) {
    timeStamps = getTimestamps();
  }

  List<DateTime> generateTimestamps(DateTime start, DateTime end, Duration interval) {
    List<DateTime> timestamps = [start];
    DateTime curr = start.add(interval);

    while (curr.isBefore(end)) {
      timestamps.add(curr);
      curr = curr.add(interval);
    }

    return timestamps;
  }

  List<DateTime> getTimestamps() {
    Set<DateTime> timestampSet = report
        .devices()
        .map((d) => d.dataPoints(testing: true).map((d) => d.time).toSet())
        .fold({}, (a, b) => b..addAll(a));

    return timestampSet.toList()..sort();
  }

  void test() {
    DateTime init = timeStamps.first;
    DateTime start = init.add(Settings.shared.minScanDuration);
    DateTime end = timeStamps.last;
    timeStamps = generateTimestamps(start, end, Settings.shared.scanInterval);
    print(timeStamps.toString());
    timeStamps.forEach((ts) {
      Map<String, Device> deviceEntries = {};
      Set<Device> filteredDevices =
          report.devices().where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts))).toSet();
      filteredDevices.forEach((d) {
        Set<Datum> dataPoints = d.dataPoints(testing: true).where((dp) => dp.time.isBefore(ts)).toSet();
        deviceEntries[d.id] = Device(d.id, d.name, d.platformName, d.manufacturer, dataPoints: dataPoints);
      });
      if (deviceEntries.length < 2) {
        return;
      }
      Report r = Report(deviceEntries);
      r.refreshCache();
      Set<Device> devicesToFlag = filteredDevices.where((d) {
        bool a = !flaggedDevices.contains(d);
        bool b = r.riskScore(d) > r.riskScoreStats.tukeyExtremeUpperLimit;
        return a && b;
      }).toSet();
      if (!devicesToFlag.isEmpty) {
        if (devicesToFlag.length > 10) {
          Duration d = ts.difference(init);
          print("Scanned " +
              devicesToFlag.length.toString() +
              " devices after " +
              d.inHours.toString() +
              " hours and " +
              (d - Duration(hours: d.inHours)).inMinutes.toString() +
              " minutes");
        }
        flaggedDevices.addAll(devicesToFlag);
        flaggedDevicesWithTimeStamps[ts] = devicesToFlag;
      }
    });
    flaggedDevicesWithTimeStamps.forEach(
        (timestamp, listOfDevices) => print(timestamp.toString() + ": " + listOfDevices.map((e) => e.id).join(", ")));
    print("Flagged " + flaggedDevices.length.toString() + " of " + report.devices().length.toString() + " devices");
  }
}

class FlaggedDevice {
  Device device;
  late DateTime time;

  FlaggedDevice(this.device) {
    this.time = DateTime.now();
  }
}
