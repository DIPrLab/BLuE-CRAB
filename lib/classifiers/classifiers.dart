import 'package:blue_crab/classifiers/classifier.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
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
    clusters = clusters.sorted((c1, c2) {
      double a = 0;
      double b = 0;
      try {
        a = c1.instances.map((i) => i.location.fold(0.toDouble(), (a, b) => a + b)).average;
      } catch (e) {}
      try {
        b = c2.instances.map((i) => i.location.fold(0.toDouble(), (a, b) => a + b)).average;
      } catch (e) {}
      return a.compareTo(b);
    });
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
    clusters =
        clusters.sorted((c1, c2) => c1.location.distanceFromOrigin().compareTo(c2.location.distanceFromOrigin()));
    num lower;
    num upper;
    try {
      lower = clusters.first.instances.map((i) => report.riskScore(report.data[i.id]!)).max;
      upper = clusters.last.instances.map((i) => report.riskScore(report.data[i.id]!)).min;
    } catch (e) {
      return Set.identity();
    }
    final num limit = upper + (upper - lower) * 1.5;
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
  Set<Device> getRiskyDevices(Report report) => List.generate(8, (x) => x + 2)
      .map((k) {
        final List<Instance> instances =
            report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
        final List<Cluster> clusters = initialClusters(k, instances, seed: 0);
        kMeans(clusters: clusters, instances: instances);
        return clusters;
      })
      .map((clusters) =>
          clusters.sorted((c1, c2) => c1.location.distanceFromOrigin().compareTo(c2.location.distanceFromOrigin())))
      .map((e) => e.last.instances)
      .sorted((a, b) => a.length.compareTo(b.length))
      .first
      .map((e) => report.data[e.id]!)
      .toSet();
}

class RssiStability extends Classifier {
  @override
  String name() => "RSSI Stability";

  @override
  Set<Device> getRiskyDevices(Report report) {
    num timeThreshold;
    num distanceThreshold;
    try {
      timeThreshold = report.devices().map((e) => e.timeTravelled.inSeconds).getBreaks().sorted()[1];
      distanceThreshold = report.devices().map((e) => e.distanceTravelled).getBreaks().sorted()[1];
    } catch (e) {
      return Set.identity();
    }

    return report
        .devices()
        .where((e) => e.timeTravelled.inSeconds > timeThreshold)
        .where((e) => e.distanceTravelled > distanceThreshold)
        .where((device) => device
            .dataPoints()
            .smoothedDatumByMovingAverage(const Duration(seconds: 5))
            .segment()
            .map((e) => e.map((f) => f.rssi).standardDeviation())
            .any((e) => e < 5))
        .toSet();
  }
}

class RssiProximity extends Classifier {
  @override
  String name() => "RSSI Proximity";

  @override
  Set<Device> getRiskyDevices(Report report) {
    num timeThreshold;
    num distanceThreshold;
    try {
      timeThreshold = report.devices().map((e) => e.timeTravelled.inSeconds).getBreaks().sorted()[1];
      distanceThreshold = report.devices().map((e) => e.distanceTravelled).getBreaks().sorted()[1];
    } catch (e) {
      return Set.identity();
    }

    return report
        .devices()
        .where((e) => e.timeTravelled.inSeconds > timeThreshold)
        .where((e) => e.distanceTravelled > distanceThreshold)
        .where((device) => device
            .dataPoints()
            .smoothedDatumByMovingAverage(const Duration(seconds: 5))
            .orderedPairs()
            .fold(List<(DateTime, DateTime)>.empty(growable: true), (acc, e) {
              if (e.$2.rssi < -75) {
                return acc;
              }
              if (acc.isEmpty) {
                acc.add((e.$1.time, e.$2.time));
              } else if (acc.last.$2 == e.$1.time) {
                acc.last = (acc.last.$1, e.$2.time);
              } else {
                acc.add((e.$2.time, e.$2.time));
              }
              return acc;
            })
            .map((e) => e.$2.difference(e.$1))
            .any((e) => e.inSeconds > 30))
        .toSet();
  }
}
