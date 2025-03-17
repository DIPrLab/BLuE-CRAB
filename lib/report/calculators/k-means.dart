import 'package:blue_crab/report/calculators/calculators.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:collection/collection.dart';
import 'package:k_means_cluster/k_means_cluster.dart';

class KMeans extends Classifier {
  @override
  Iterable<Device> getRiskyDevices(Report report) {
    List<Instance> instances = report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
    List<Cluster> clusters = initialClusters(3, instances, seed: 0);
    kMeans(clusters: clusters, instances: instances);
    clusters = clusters.sorted((c1, c2) => c1.instances
        .map((i) => i.location.fold<double>(0.0, (a, b) => a + b))
        .fold<double>(0.0, (a, b) => a + b)
        .compareTo(c2.instances.map((i) => i.location.fold<double>(0.0, (a, b) => a + b)).average));
    clusters.forEach((c) => print([c.id, c.instances.map((d) => d.id).join("\n"), ""].join("\n")));
    return clusters.last.instances.map((e) => report.data[e.id]!);
  }
}
