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

  @override
  String csvName() => "BLE_DOUBT";

  double distanceThreshold = 300;
  Duration timeThreshold = const Duration(seconds: 300);

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

  @override
  String csvName() => "AIRGUARD";

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
  String csvName() => name();

  @override
  Set<Device> getRiskyDevices(Report report) =>
      report.devices().where((d) => report.riskScore(d) > report.riskScoreStats.tukeyMildUpperLimit).toSet();
}

class KMeans extends Classifier {
  @override
  String name() => "K-Means";

  @override
  String csvName() => "K_MEANS";

  int k = 5;

  @override
  Set<Device> getRiskyDevices(Report report) {
    Set<Device> result = {};
    final List<Instance> instances =
        report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
    final List<Cluster> clusters = initialClusters(k, instances);
    kMeans(clusters: clusters, instances: instances);
    try {
      result = clusters
          .where((c) => c.location.any((e) => e > 0))
          .map((c) {
            num distance = 0;
            try {
              distance = c.location.distanceFromOrigin();
            } catch (e) {}
            return (cluster: c, distance: distance);
          })
          .sorted((c1, c2) => c1.distance.compareTo(c2.distance))
          .last
          .cluster
          .instances
          .map((e) => report.data[e.id]!)
          .toSet();
    } catch (e) {}
    return result;
  }
}

class IQRKMeansHybrid extends Classifier {
  @override
  String name() => "IQR / K-Means Hybrid";

  @override
  String csvName() => "IQR_K_MEANS_HYBRID";

  @override
  Set<Device> getRiskyDevices(Report report) {
    final List<Instance> instances =
        report.devices().map((d) => Instance(location: report.riskScores(d), id: d.id)).toList();
    num lower;
    num upper;
    num? limit;
    for (int k = 10; k > 2; k--) {
      List<Cluster> clusters = initialClusters(k, instances);
      kMeans(clusters: clusters, instances: instances);
      clusters = clusters
          .map((c) => (cluster: c, distance: c.location.fold(0.toDouble(), (acc, e) => acc + e)))
          .sorted((c1, c2) => c1.distance.compareTo(c2.distance))
          .map((e) => e.cluster)
          .toList();
      try {
        lower = clusters.first.instances.map((i) => report.riskScore(report.data[i.id]!)).max;
        upper = clusters.elementAt(clusters.length - 2).instances.map((i) => report.riskScore(report.data[i.id]!)).min;
        limit = upper + (upper - lower) * 1.5;
      } catch (e) {
        continue;
      }
      break;
    }
    return report.devices().where((d) => report.riskScore(d) > (limit ?? double.infinity)).toSet();
  }
}

class Permissive extends Classifier {
  @override
  String name() => "Permissive";

  @override
  String csvName() => "PERMISSIVE";

  @override
  Set<Device> getRiskyDevices(Report report) => report.devices();
}

class DbScan extends Classifier {
  @override
  String name() => "DB Scan";

  @override
  String csvName() => "DB_SCAN";

  @override
  Set<Device> getRiskyDevices(Report report) {
    final Set<Device> result = {};
    Set<Device> newDevices = {};
    do {
      final DBSCAN dbscan = DBSCAN()
        ..run(report
            .devices()
            .difference(result)
            .map((d) => report.riskScores(d).map((x) => x.toDouble()).toList())
            .toList());
      final Map<int, Set<Device>> clusters = {};
      List.generate(dbscan.dataset.length, (i) => i).forEach((i) {
        if (!clusters.keys.contains(dbscan.label![i])) {
          clusters[dbscan.label![i]] = {};
        }
        clusters[dbscan.label![i]]!
            .addAll(report.devices().where((d) => report.riskScores(d).equals(dbscan.dataset[i])));
      });
      newDevices = clusters[-1] ?? {};
      result.addAll(newDevices);
    } while (newDevices.isNotEmpty);
    return result;
  }
}

class SmallestKCluster extends Classifier {
  @override
  String name() => "Smallest K-Cluster";

  @override
  String csvName() => "SMALLEST_K_CLUSTER";

  int? k;
  Set<Device>? cluster;

  @override
  Set<Device> getRiskyDevices(Report report) {
    final ({Set<Device> cluster, int k}) result = List.generate(8, (x) => x + 2)
        .map((k) => (k: k, cluster: (KMeans()..k = k).getRiskyDevices(report)))
        .sorted((a, b) => a.cluster.length.compareTo(b.cluster.length))
        .first;
    k = result.k;
    cluster = result.cluster;
    return result.cluster.map((e) => report.data[e.id]!).toSet();
  }
}

class SCORE extends Classifier {
  @override
  String name() => "SCORE";

  @override
  String csvName() => name();

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

class SCORE_00 extends Classifier {
  @override
  String name() => "SCORE_00";

  @override
  String csvName() => name();

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
        .toSet();
  }
}

class SCORE_01 extends Classifier {
  @override
  String name() => "SCORE_01";

  @override
  String csvName() => name();

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
        .where((d) => isStable(d.$2))
        .map((d) => d.$1)
        .toSet();
  }
}

class SCORE_10 extends Classifier {
  @override
  String name() => "SCORE_10";

  @override
  String csvName() => name();

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
        .where((d) => hasBeenClose(d.$2))
        .map((d) => d.$1)
        .toSet();
  }
}

class SCORE_11 extends Classifier {
  @override
  String name() => "SCORE_11";

  @override
  String csvName() => name();

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
        .where((d) => hasBeenClose(d.$2))
        .where((d) => isStable(d.$2))
        .map((d) => d.$1)
        .toSet();
  }
}
