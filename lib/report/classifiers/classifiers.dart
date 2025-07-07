import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/report/classifiers/classifier.dart';
import 'package:blue_crab/report/datum.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:collection/collection.dart';
import 'package:k_means_cluster/k_means_cluster.dart';
import 'package:simple_cluster/simple_cluster.dart';

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
    return clusters[-1] ?? {};
  }
}

class SmallestKCluster extends Classifier {
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

  List<List<Datum>> segment2(Report report, Device device, Duration segmentLength, Duration skipLength) {
    final DateTime first = report.data.values
        .map((e) => e.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).first)
        .sorted((a, b) => a.compareTo(b))
        .first;
    final DateTime last = report.data.values
        .map((e) => e.dataPoints().map((e) => e.time).sorted((a, b) => a.compareTo(b)).last)
        .sorted((a, b) => a.compareTo(b))
        .last;
    return List.generate(
            (last.difference(first).inSeconds / skipLength.inSeconds).toInt() + 1, (e) => first.add(segmentLength * e))
        .mapOrderedPairs((e) => device
            .dataPoints()
            .where((datum) =>
                datum.time.isAfter(e.$1) || datum.time.isBefore(e.$2) || datum.time == e.$1 || datum.time == e.$2)
            .toList());
  }

  @override
  Set<Device> getRiskyDevices(Report report) => report
      .devices()
      .where((e) => e.timeTravelled.inSeconds > report.devices().map((e) => e.timeTravelled.inSeconds).median())
      .where((e) => e.distanceTravelled > report.devices().map((e) => e.distanceTravelled).median())
      .where((device) => device
          .dataPoints()
          .sorted((a, b) => a.time.compareTo(b.time))
          .smoothedDatumByMovingAverage(5)
          .segment()
          .map((e) => e.map((f) => f.rssi).standardDeviation())
          .any((e) => e > 5))
      .toSet();
}
