import 'dart:core';
import 'dart:math';
import 'package:collection/collection.dart';

class Jenks {
  List<num> list = List.empty(growable: true);

  Breaks computeBreaks() {
    final List<num> list = toSortedArray();

    final int uniqueValues = countUnique(list);
    if (uniqueValues <= 3) {
      return computeBreaks2(list, uniqueValues);
    }

    Breaks lastBreaks = computeBreaks2(list, 2);
    num lastGvf = lastBreaks.gvf();
    num lastImprovement = lastGvf - computeBreaks2(list, 1).gvf();

    for (int i = 3; i <= min(6, uniqueValues); ++i) {
      final Breaks breaks = computeBreaks2(list, i);
      final num gvf = breaks.gvf();
      final num marginalImprovement = gvf - lastGvf;
      if (marginalImprovement < lastImprovement) {
        return lastBreaks;
      }
      lastBreaks = breaks;
      lastGvf = gvf;
      lastImprovement = marginalImprovement;
    }

    return lastBreaks;
  }

  List<num> toSortedArray() => list.sorted((a, b) => a.compareTo(b));

  int countUnique(List<num> sortedList) => sortedList.toSet().length;

  Breaks computeBreaks1(int numclass) => computeBreaks3(toSortedArray(), numclass, Identity());

  Breaks computeBreaks2(List<num> list, int numclass) => computeBreaks3(list, numclass, Identity());

  Breaks computeBreaks3(List<num> list, int numclass, DoubleFunction transform) {
    final int numdata = list.length;

    if (numdata == 0) {
      return Breaks(List.empty(growable: true), List.empty(growable: true));
    }

    final List<List<num>> mat1 = List.generate(numdata + 1, (_) => List.generate(numclass + 1, (_) => 0));
    final List<List<num>> mat2 = List.generate(numdata + 1, (_) => List.generate(numclass + 1, (_) => 0));

    for (int i = 1; i <= numclass; i++) {
      mat1[1][i] = 1;
      mat2[1][i] = 0;
      for (int j = 2; j <= numdata; j++) {
        mat2[j][i] = double.maxFinite;
      }
    }
    num v = 0;
    for (int l = 2; l <= numdata; l++) {
      num s1 = 0;
      num s2 = 0;
      num w = 0;
      for (int m = 1; m <= l; m++) {
        final int i3 = l - m + 1;
        final num val = transform.apply(list[i3 - 1]);

        s2 += val * val;
        s1 += val;

        w++;
        v = s2 - (s1 * s1) / w;
        final int i4 = i3 - 1;
        if (i4 != 0) {
          for (int j = 2; j <= numclass; j++) {
            if (mat2[l][j] >= (v + mat2[i4][j - 1])) {
              mat1[l][j] = i3;
              mat2[l][j] = v + mat2[i4][j - 1];
            }
          }
        }
      }
      mat1[l][1] = 1;
      mat2[l][1] = v;
    }
    int k = numdata;

    final List<int> kclass = List.generate(numclass, (e) => 0);

    kclass[numclass - 1] = list.length - 1;

    for (int j = numclass; j >= 2; j--) {
      kclass[j - 2] = mat1[k][j].toInt() - 2;
      k = mat1[k][j].toInt() - 1;
    }
    return Breaks(list, kclass);
  }
}

abstract class DoubleFunction {
  num apply(num x);
}

class Log10 implements DoubleFunction {
  double logBase(num x, num base) => log(x) / log(base);
  double log10(num x) => log(x) / ln10;

  @override
  num apply(num x) => log10(x);
}

class Identity implements DoubleFunction {
  @override
  num apply(num x) => x;
}

class Breaks {
  Breaks(this.sortedValues, this.breaks);

  List<num> sortedValues;
  List<int> breaks;

  num gvf() {
    final num sdam = sumOfSquareDeviations(sortedValues);
    num sdcm = 0.0;
    for (int i = 0; i != breaks.length; ++i) {
      sdcm += sumOfSquareDeviations(classList(i));
    }
    return (sdam - sdcm) / sdam;
  }

  num sumOfSquareDeviations(List<num> values) {
    num sum = 0.0;
    values.forEach((value) {
      final num sqDev = pow(value - values.average, 2);
      sum += sqDev;
    });
    return sum;
  }

  List<num> getValues() => sortedValues;

  List<num> classList(int i) {
    final int classStart = (i == 0) ? 0 : breaks[i - 1] + 1;
    return List.generate(breaks[i] - classStart + 1, (j) => sortedValues[classStart + j]);
  }

  num getClassMin(int classIndex) => classIndex == 0 ? sortedValues[0] : sortedValues[breaks[classIndex - 1] + 1];

  num getClassMax(int classIndex) => sortedValues[breaks[classIndex]];

  num getClassCount(int classIndex) => classIndex == 0 ? breaks[0] + 1 : breaks[classIndex] - breaks[classIndex - 1];

  num classOf(num value) {
    for (int i = 0; i != breaks.length; ++i) {
      if (value <= getClassMax(i)) {
        return i;
      }
    }
    return breaks.length - 1;
  }
}
