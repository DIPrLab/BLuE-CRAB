import 'package:blue_crab/classifiers/classifiers.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/device/device.dart';

abstract class Classifier {
  String name();
  Set<Device> getRiskyDevices(Report report);
  Set<String> getRiskyDeviceIDs(Report report) => getRiskyDevices(report).map((d) => d.id).toSet();
  static List<Classifier> classifiers = [
    RSSI(),
    SmallestKCluster(),
    DbScan(),
    IQR(),
    IQRKMeansHybrid(),
    KMeans(),
    Permissive()
  ];
}
