import 'package:blue_crab/extensions/collections.dart';

class Stats {
  final List<num> input;

  late num average = input.average();
  late num median = input.median();
  late num standardDeviation = input.standardDeviation();
  late num mad = input.mad();
  late num iqr = input.iqr();
  late num iqrLowerLimit = input.iqrLimits().$1;
  late num iqrUpperLimit = input.iqrLimits().$2;
  late num tukeyMildLowerLimit = iqrLowerLimit;
  late num tukeyMildUpperLimit = iqrUpperLimit;
  late num tukeyExtremeLowerLimit = input.tukeyLimits().$1;
  late num tukeyExtremeUpperLimit = input.tukeyLimits().$4;

  late Iterable<num> lowOutliers = input.iqrOutliers().$1;
  late Iterable<num> highOutliers = input.iqrOutliers().$2;
  late Iterable<num> extremeLowOutliers = input.tukeyOutliers().$1;
  late Iterable<num> mildLowOutliers = input.tukeyOutliers().$2;
  late Iterable<num> mildHighOutliers = input.tukeyOutliers().$3;
  late Iterable<num> extremeHighOutliers = input.tukeyOutliers().$4;

  num zScore(num x) => standardDeviation == 0 ? 0 : (x - average) / standardDeviation;

  factory Stats.fromData(Iterable<num> input) => Stats(input.toList()..sort());
  Stats(this.input);
}
