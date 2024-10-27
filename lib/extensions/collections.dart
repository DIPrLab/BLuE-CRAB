import "dart:math";
import "dart:core";

extension IterableStats on Iterable<num> {
  num average() => this.fold(0.0, (a, b) => a + b) / this.length;

  num standardDeviation() => sqrt(this.fold(0.0, (a, b) => a + pow(b - average(), 2)) / this.length);
}

extension ListStats on List<num> {
  num median() => this.length.isEven
      ? (this..sort((a, b) => a.compareTo(b))).getRange((this.length ~/ 2) - 1, (this.length ~/ 2) + 1).average()
      : (this..sort((a, b) => a.compareTo(b)))[this.length ~/ 2];

  // num mad() => this.map((x) => x - this.average().abs()).average();
  num mad() => this.map((x) => (x - this.median()).abs()).toList().median();

  (List<num>, List<num>) split() =>
      (this.getRange(0, this.length ~/ 2).toList(), this.getRange((this.length / 2).ceil(), this.length).toList());

  num q3() => this.split().$2.median();
  num q1() => this.split().$1.median();

  num iqr() => q3() - q1();

  (num, num) iqrLimits() => (q1() - (iqr() * 1.5), q3() + (iqr() * 1.5));

  (Iterable<num> lowOutliers, Iterable<num> highOutliers) iqrOutliers() =>
      (this.where((element) => element < iqrLimits().$1), this.where((element) => element > iqrLimits().$2));

  (num, num, num, num) tukeyLimits() =>
      (q1() - (iqr() * 3), q1() - (iqr() * 1.5), q3() + (iqr() * 1.5), q3() + (iqr() * 3));

  (Iterable<num>, Iterable<num>, Iterable<num>, Iterable<num>) tukeyOutliers() {
    Iterable<num> extremeLowOutliers = this.where((element) => element < tukeyLimits().$1);
    Iterable<num> mildLowOutliers = this.where((element) => element < tukeyLimits().$2);
    Iterable<num> mildHighOutliers = this.where((element) => element > tukeyLimits().$3);
    Iterable<num> extremeHighOutliers = this.where((element) => element > tukeyLimits().$4);
    return (extremeLowOutliers, mildLowOutliers, mildHighOutliers, extremeHighOutliers);
  }
}
