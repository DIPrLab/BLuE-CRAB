import "dart:core";
import "dart:math";

// import "package:statistics/statistics.dart";

enum SmoothingMethod { padding, resizing, skipping }

extension IterableStats on Iterable<num> {
  num avg() => fold(0.toDouble(), (a, b) => a + b) / length;

  num standardDeviation() => sqrt(fold(0.toDouble(), (a, b) => a + pow(b - avg(), 2)) / length);
}

extension ListStats on List<num> {
  num median() => length.isEven
      ? (this..sort((a, b) => a.compareTo(b))).getRange((length ~/ 2) - 1, (length ~/ 2) + 1).avg()
      : (this..sort((a, b) => a.compareTo(b)))[length ~/ 2];

  // num mad() => map((x) => x - average().abs()).average();
  num mad() => map((x) => (x - median()).abs()).toList().median();

  (List<num>, List<num>) split() => (getRange(0, length ~/ 2).toList(), getRange((length / 2).ceil(), length).toList());

  num q3() => split().$2.median();
  num q1() => split().$1.median();

  num iqr() => q3() - q1();

  (num, num) iqrLimits() => (q1() - (iqr() * 1.5), q3() + (iqr() * 1.5));

  (Iterable<num>, Iterable<num>) iqrOutliers() {
    final Iterable<num> lowOutliers = where((element) => element < iqrLimits().$1);
    final Iterable<num> highOutliers = where((element) => element > iqrLimits().$2);
    return (lowOutliers, highOutliers);
  }

  (num, num, num, num) tukeyLimits() =>
      (q1() - (iqr() * 3), q1() - (iqr() * 1.5), q3() + (iqr() * 1.5), q3() + (iqr() * 3));

  (Iterable<num>, Iterable<num>, Iterable<num>, Iterable<num>) tukeyOutliers() {
    final Iterable<num> extremeLowOutliers = where((element) => element < tukeyLimits().$1);
    final Iterable<num> mildLowOutliers = where((element) => element < tukeyLimits().$2);
    final Iterable<num> mildHighOutliers = where((element) => element > tukeyLimits().$3);
    final Iterable<num> extremeHighOutliers = where((element) => element > tukeyLimits().$4);
    return (extremeLowOutliers, mildLowOutliers, mildHighOutliers, extremeHighOutliers);
  }

  num distanceFromOrigin() => sqrt(map((e) => e.toDouble() * e.toDouble()).fold(0.toDouble(), (a, b) => a + b));

  List<num> smoothedByMovingAverage(int factor, SmoothingMethod smoothingMethod) {
    final List<num> source = List.from(this);
    final List<num> result = [];
    void smooth(int f) {
      final value = source.getRange(0, f).avg();
      result.add(value);
      source.removeAt(0);
    }

    if (smoothingMethod == SmoothingMethod.padding) {
      source.insertAll(0, List<double>.generate(factor - 1, (e) => first.toDouble()));
    } else if (smoothingMethod == SmoothingMethod.resizing) {
      List.generate(min(factor, source.length) - 1, (e) => e + 1).forEach((e) {
        final num v = source.first;
        smooth(e);
        source.insert(0, v);
      });
    } else if (smoothingMethod == SmoothingMethod.skipping) {
      // Do nothing
    }
    while (source.length >= factor) {
      smooth(factor);
    }
    return result;
  }

  List<num> smoothedByExponentiallyWeightedMovingAverage(num alpha) => List.generate(length, (e) => e).fold(
      List<num>.empty(growable: true),
      (acc, e) => e == 0 ? [first] : acc + [(alpha * this[e]) + ((1 - alpha) * acc.last)]);
}

extension CommonElements<T> on Set<Set<T>> {
  Set<Set<T>> combineSetsWithCommonElements() {
    final result = Set<Set<T>>.from(this);
    result.forEach((s1) => result.difference({s1}).where((s2) => s1.intersection(s2).isNotEmpty).forEach((s2) {
          s1 = s1.union(s2);
          result.remove(s2);
        }));
    return result;
  }
}
