import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';

abstract class Classifier {
  Iterable<Device> getRiskyDevices(Report r);
  Set<String> getRiskyDeviceIDs(Report r) => getRiskyDevices(r).map((d) => d.id).toSet();
}
