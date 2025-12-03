import 'package:blue_crab/classifiers/classifier.dart';
import 'package:blue_crab/dataset_formats/report/report.dart';
import 'package:blue_crab/datum/datum.dart';
import 'package:blue_crab/device/device.dart';
import 'package:blue_crab/extensions/collections.dart';
import 'package:blue_crab/extensions/geolocator.dart';
import 'package:blue_crab/extensions/ordered_pairs.dart';
import 'package:blue_crab/settings.dart';
import 'package:collection/collection.dart';
import 'package:k_means_cluster/k_means_cluster.dart';
import 'package:simple_cluster/simple_cluster.dart';

class BLEDoubt extends Classifier {
  @override
  String name() => "BLEDoubt";

  double distanceThreshold = 420;
  Duration timeThreshold = const Duration(minutes: 10);

  @override
  Set<Device> getRiskyDevices(Report report) => report
      .devices()
      .where((d) => d.paths().any((path) {
            final Duration time = path.last.time.difference(path.first.time);
            final double distance = path
                .mapOrderedPairs((e) => distanceBetween(e.$1.location, e.$2.location))
                .fold(0.toDouble(), (acc, e) => acc + e);
            return distance > distanceThreshold && time > timeThreshold;
          }))
      .toSet();
}

class AirGuard extends Classifier {
  @override
  String name() => "AirGuard";

  Duration seenRecentlyThreshold = const Duration(minutes: 5);
  double distanceThreshold = 420;
  Duration timeThreshold = const Duration(seconds: 300);

  bool seenRecently(Device d, DateTime t) => t.difference(d.dataPoints().last.time) <= seenRecentlyThreshold;

  @override
  Set<Device> getRiskyDevices(Report report) {
    final DateTime lastTimestamp =
        report.devices().map((d) => d.dataPoints().last.time).sorted((a, b) => a.compareTo(b)).last;
    return report
        .devices()
        .where((d) => seenRecently(d, lastTimestamp))
        .where((d) => d.distanceTravelled > distanceThreshold)
        .where((d) => d.timeTravelled > timeThreshold)
        .toSet();
  }
}

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
      num a = 0;
      num b = 0;
      try {
        a = c1.location.distanceFromOrigin();
      } catch (e) {}
      try {
        b = c2.location.distanceFromOrigin();
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

class RssiProximityAndStability extends Classifier {
  @override
  String name() => "RSSI Proximity and Stability";

  List<List<Datum>> closeSegments(Device device) => device
      .dataPoints()
      .smoothedDatumByMovingAverage(const Duration(seconds: 5))
      .orderedPairs()
      .fold(List<List<(Datum, Datum)>>.empty(growable: true), (acc, e) {
        if (e.$1.rssi() < -75 || e.$2.rssi() < -75) {
          return acc;
        }
        if (acc.isEmpty || acc.last.last.$2.time != e.$1.time) {
          acc.add([e]);
        } else {
          acc.last.add(e);
        }
        return acc;
      })
      .map((segment) => [segment.first.$1, ...segment.map((pair) => pair.$2)])
      .toList();

  bool isStable(List<List<Datum>> segments) => segments
      .map((e) => e
          .map((f) => f.rssiBackingData())
          .fold(List<int>.empty(growable: true), (acc, e) => acc + e)
          .standardDeviation())
      .any((e) => e < 5);

  bool hasBeenClose(List<List<Datum>> segments) =>
      segments.map((e) => e.last.time.difference(e.first.time)).any((e) => e.inSeconds > 30);

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
        .where((d) => d.timeTravelled.inSeconds > timeThreshold)
        .where((d) => d.distanceTravelled > distanceThreshold)
        .map((d) => (d, closeSegments(d)))
        .where((d) => !Settings().proximityMetricEnabled || hasBeenClose(d.$2))
        .where((d) => !Settings().stabilityMetricEnabled || isStable(d.$2))
        .map((d) => d.$1)
        .toSet();
  }
}
