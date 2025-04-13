import 'package:blue_crab/report/classifiers/classifiers.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';

abstract class Classifier {
  String name();
  Set<Device> getRiskyDevices(Report report);
  Set<String> getRiskyDeviceIDs(Report report) => getRiskyDevices(report).map((d) => d.id).toSet();
  static List<Classifier> classifiers = [
    Smallest_K_Cluster(),
    DbScan(),
    IQR(),
    IQRKMeansHybrid(),
    KMeans(),
    Permissive()
  ];
}
