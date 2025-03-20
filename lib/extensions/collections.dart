import "dart:math";
import "dart:core";

extension IterableStats on Iterable<num> {
  num average() => fold(0.0, (a, b) => a + b) / length;

  num standardDeviation() => sqrt(fold(0.0, (a, b) => a + pow(b - average(), 2)) / length);
}

extension ListStats on List<num> {
  num median() => length.isEven
      ? (this..sort((a, b) => a.compareTo(b))).getRange((length ~/ 2) - 1, (length ~/ 2) + 1).average()
      : (this..sort((a, b) => a.compareTo(b)))[length ~/ 2];

  // num mad() => map((x) => x - average().abs()).average();
  num mad() => map((x) => (x - median()).abs()).toList().median();

  (List<num>, List<num>) split() => (getRange(0, length ~/ 2).toList(), getRange((length / 2).ceil(), length).toList());

  num q3() => split().$2.median();
  num q1() => split().$1.median();

  num iqr() => q3() - q1();

  (num, num) iqrLimits() => (q1() - (iqr() * 1.5), q3() + (iqr() * 1.5));

  (Iterable<num>, Iterable<num>) iqrOutliers() {
    Iterable<num> lowOutliers = where((element) => element < iqrLimits().$1);
    Iterable<num> highOutliers = where((element) => element > iqrLimits().$2);
    return (lowOutliers, highOutliers);
  }

  (num, num, num, num) tukeyLimits() =>
      (q1() - (iqr() * 3), q1() - (iqr() * 1.5), q3() + (iqr() * 1.5), q3() + (iqr() * 3));

  (Iterable<num>, Iterable<num>, Iterable<num>, Iterable<num>) tukeyOutliers() {
    Iterable<num> extremeLowOutliers = where((element) => element < tukeyLimits().$1);
    Iterable<num> mildLowOutliers = where((element) => element < tukeyLimits().$2);
    Iterable<num> mildHighOutliers = where((element) => element > tukeyLimits().$3);
    Iterable<num> extremeHighOutliers = where((element) => element > tukeyLimits().$4);
    return (extremeLowOutliers, mildLowOutliers, mildHighOutliers, extremeHighOutliers);
  }
}

extension CommonElements<T> on Set<Set<T>> {
  Set<Set<T>> combineSetsWithCommonElements() {
    var result = Set<Set<T>>.from(this);
    result.forEach((s1) => result.difference({s1}).where((s2) => s1.intersection(s2).isNotEmpty).forEach((s2) {
          s1 = s1.union(s2);
          result.remove(s2);
        }));
    return result;
  }
}
