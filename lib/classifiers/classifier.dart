import 'package:blue_crab/classifiers/classifiers.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/device/device.dart';

abstract class Classifier {
  String name();
  String csvName();
  Set<Device> getRiskyDevices(Report report);
  Set<String> getRiskyDeviceIDs(Report report) => getRiskyDevices(report).map((d) => d.id).toSet();
  static List<Classifier> classifiers = [
    AirGuard(),
    BLEDoubt(),
    // IQR(),
    IQRKMeansHybrid(),
    // KMeans(),
    SCORE_00(),
    SCORE_01(),
    SCORE_10(),
    SCORE_11(),
    SmallestKCluster(),
    // SCORE(),
    // DbScan(),
    // Permissive(),
  ];
}
