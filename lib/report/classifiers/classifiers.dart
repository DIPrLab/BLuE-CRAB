import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/report/classifiers/classifier.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:collection/collection.dart';
import 'package:k_means_cluster/k_means_cluster.dart';
import 'package:simple_cluster/simple_cluster.dart';
import "package:statistics/statistics.dart";

class IQR extends Classifier {
  @override
  String name() => "IQR";

  @override
  Set<Device> getRiskyDevices(Report report) =>
      report.devices().where((d) => report.riskScore(d) > report.riskScoreStats.tukeyMildUpperLimit).toSet();
}

class KMeans extends Classifier {
  @override
  String name() => "K-Means";

  @override
  Set<Device> getRiskyDevices(Report report) {
    final List<Instance> instances =
        report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
    List<Cluster> clusters = initialClusters(3, instances, seed: 0);
    kMeans(clusters: clusters, instances: instances);
    clusters = clusters.sorted((c1, c2) => c1.instances
        .map((i) => i.location.fold(0.toDouble(), (a, b) => a + b))
        .fold<double>(0, (a, b) => a + b)
        .compareTo(c2.instances.map((i) => i.location.fold(0.toDouble(), (a, b) => a + b)).average));
    return clusters.last.instances.map((e) => report.data[e.id]!).toSet();
  }
}

class IQRKMeansHybrid extends Classifier {
  @override
  String name() => "IQR / K-Means Hybrid";

  @override
  Set<Device> getRiskyDevices(Report report) {
    final List<Instance> instances =
        report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
    List<Cluster> clusters = initialClusters(5, instances, seed: 0);
    kMeans(clusters: clusters, instances: instances);
    clusters = clusters.sorted((c1, c2) => c1.instances
        .map((i) => i.location.fold<double>(0, (a, b) => a + b))
        .fold<double>(0, (a, b) => a + b)
        .compareTo(c2.instances.map((i) => i.location.fold<double>(0, (a, b) => a + b)).average));
    final num lower = clusters.first.instances.map((i) => report.riskScore(report.data[i.id]!)).max;
    final num upper = clusters.reversed.toList()[1].instances.map((i) => report.riskScore(report.data[i.id]!)).min;
    final num limit = (upper - lower) * 3;
    return report.devices().where((d) => report.riskScore(d) > limit).toSet();
  }
}

class Permissive extends Classifier {
  @override
  String name() => "Permissive";

  @override
  Set<Device> getRiskyDevices(Report report) => report.devices().toSet();
}

class DbScan extends Classifier {
  @override
  String name() => "DB Scan";

  @override
  Set<Device> getRiskyDevices(Report report) {
    final DBSCAN dbscan = DBSCAN(epsilon: 3)
      ..run(report.devices().map((d) => report.riskScores(d).map((x) => x.toDouble()).toList()).toList());
    final Map<int, Set<Device>> clusters = {};
    List.generate(dbscan.dataset.length, (i) => i).forEach((i) {
      if (!clusters.keys.contains(dbscan.label![i])) {
        clusters[dbscan.label![i]] = {};
      }
      clusters[dbscan.label![i]]!.addAll(report.devices().where((d) => report.riskScores(d).equals(dbscan.dataset[i])));
    });
    // print(clusters);
    return clusters[-1] ?? {};
  }
}

class Smallest_K_Cluster extends Classifier {
  @override
  String name() => "Smallest K-Cluster";

  @override
  Set<Device> getRiskyDevices(Report report) => List.generate(5, (x) => x + 2)
      .map((k) {
        final List<Instance> instances =
            report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
        final List<Cluster> clusters = initialClusters(k, instances, seed: 0);
        kMeans(clusters: clusters, instances: instances);
        return clusters;
      })
      .map((clusters) => clusters.sorted((c1, c2) =>
          c1.location.fold<double>(0, (a, b) => a + b).compareTo(c2.location.fold<double>(0, (a, b) => a + b))))
      .map((clusters) {
        final num lower = clusters.first.instances.map((i) => report.riskScore(report.data[i.id]!)).max;
        final num upper = clusters.reversed.toList()[1].instances.map((i) => report.riskScore(report.data[i.id]!)).min;
        final num limit = (upper - lower) * 3;
        return report.devices().where((d) => report.riskScore(d) > limit).toSet();
      })
      .sorted((a, b) => a.length.compareTo(b.length))
      .first;
}

class RSSI extends Classifier {
  @override
  String name() => "RSSI Confidence";

  List<Cluster> cluster(int k, Iterable<Instance> dataPoints) {
    final List<Instance> instances = dataPoints.toList();
    final List<Cluster> clusters = initialClusters(k, instances, seed: 0);
    kMeans(clusters: clusters, instances: instances);
    return clusters;
  }

  List<Cluster> sortedClusters(Report report) =>
      cluster(3, report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)))
          .sorted((a, b) => a.location.distanceFromOrigin().compareTo(b.location.distanceFromOrigin()));

  @override
  Set<Device> getRiskyDevices(Report report) {
    final List<double> rssiAverages = report
        .devices()
        .sorted((a, b) => report.riskScore(a).compareTo(report.riskScore(b)))
        .map((d) => d.dataPoints().map((dp) => dp.rssi.toDouble()).average)
        .toList();
    print("");
    return report
        .devices()
        .where((e) => !sortedClusters(report).first.instances.map((e) => e.id).map((e) => report.data[e]!).contains(e))
        .where((e) =>
            e
                .dataPoints()
                .map((e) => e.rssi.toDouble())
                .toList()
                // .smoothedByMovingAverage(5, SmoothingMethod.resizing)
                .smoothedByExponentiallyWeightedMovingAverage(0.7)
                .avg() >
            -70)
        .toSet();
  }
}
