import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';

abstract class Classifier {
  String name = "";
  Iterable<Device> getRiskyDevices(Report report);
  Set<String> getRiskyDeviceIDs(Report report) => getRiskyDevices(report).map((d) => d.id).toSet();
}
