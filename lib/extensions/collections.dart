import "dart:core";
import "dart:math";

import "package:collection/collection.dart";

// import "package:statistics/statistics.dart";

enum SmoothingMethod {
  padding,
  resizing,
// skipping
}

extension IterableStats on Iterable<num> {
  num avg() => fold(0.toDouble(), (a, b) => a + b) / length;

  num standardDeviation() => sqrt(fold(0.toDouble(), (a, b) => a + pow(b - avg(), 2)) / length);

  num median() => length.isEven
      ? sorted((a, b) => a.compareTo(b)).getRange((length ~/ 2) - 1, (length ~/ 2) + 1).avg()
      : sorted((a, b) => a.compareTo(b))[length ~/ 2];
}

extension ListStats on List<num> {
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

  // Backup, safe?
  // List<num> smoothedByMovingAverageV0(int factor, SmoothingMethod smoothingMethod) =>
  //     List.generate(length, (element) => (element - factor, element + factor))
  //         .map((element) => List.generate(element.$2 - element.$1 + 1, (index) => index + element.$1))
  //         .map((element) => smoothingMethod == SmoothingMethod.padding
  //             ? element.map((e) => e.clamp(0, length - 1))
  //             : smoothingMethod == SmoothingMethod.resizing
  //                 ? element.where((e) => 0 <= e && e < length)
  //                 : element)
  //         .map((element) => element.map((e) => this[e]).average)
  //         .toList();

  List<num> smoothedByMovingAverage(int factor, SmoothingMethod smoothingMethod) =>
      List.generate(length, (index) => List.generate(2 * factor + 1, (offset) => index + offset - factor))
          .map((element) => smoothingMethod == SmoothingMethod.padding
              ? element.map((e) => e.clamp(0, length - 1))
              : smoothingMethod == SmoothingMethod.resizing
                  ? element.where((e) => 0 <= e && e < length)
                  : element)
          .map((element) => element.map((e) => this[e]).average)
          .toList();

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
