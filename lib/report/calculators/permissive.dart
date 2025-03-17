import 'package:blue_crab/report/calculators/calculators.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';

class Permissive extends Classifier {
  @override
  Iterable<Device> getRiskyDevices(Report report) => report.devices();
}
