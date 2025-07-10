import java.util.Arrays;
import java.util.LinkedList;

public class Jenks {

    private LinkedList<Double> list = new LinkedList();

    public  void addValue(double value) {
        list.add(value);
    }

    public  void addValues(double... values) {
        for (double value : values) {
            addValue(value);
        }
    }

    public  Breaks computeBreaks() {
        double[] list = toSortedArray();

        int uniqueValues = countUnique(list);
        if (uniqueValues <= 3) {
            return computeBreaks(list, uniqueValues);
        }

        Breaks lastBreaks = computeBreaks(list, 2);
        double lastGvf = lastBreaks.gvf();
        double lastImprovement = lastGvf - computeBreaks(list, 1).gvf();

        for (int i = 3; i <= Math.min(6, uniqueValues); ++i) {
            Breaks breaks = computeBreaks(list, 2);
            double gvf = breaks.gvf();
            double marginalImprovement = gvf - lastGvf;
            if (marginalImprovement < lastImprovement) {
                return lastBreaks;
            }
            lastBreaks = breaks;
            lastGvf = gvf;
            lastImprovement = marginalImprovement;
        }

        return lastBreaks;
    }

    private  double[] toSortedArray() {
        double[] values = new double[this.list.size()];
        for (int i = 0; i != values.length; ++i) {
            values[i] = this.list.get(i);
        }
        Arrays.sort(values);
        return values;
    }

    private  int countUnique(double[] sortedList) {
        int count = 1;
        for (int i = 1; i < sortedList.length; ++i) {
            if (sortedList[i] != sortedList[i - 1]) {
                count++;
            }
        }
        return count;
    }

    public  Breaks computeBreaks(int numclass) {
        return computeBreaks(toSortedArray(), numclass, new Identity());
    }

    private  Breaks computeBreaks(double[] list, int numclass) {
        return computeBreaks(list, numclass, new Identity());
    }

    private  Breaks computeBreaks(double[] list, int numclass, DoubleFunction transform) {

        int numdata = list.length;

        if (numdata == 0) {
            return new Breaks(new double[0], new int[0]);
        }

        double[][] mat1 = new double[numdata + 1][numclass + 1];
        double[][] mat2 = new double[numdata + 1][numclass + 1];

        for (int i = 1; i <= numclass; i++) {
            mat1[1][i] = 1;
            mat2[1][i] = 0;
            for (int j = 2; j <= numdata; j++) {
                mat2[j][i] = Double.MAX_VALUE;
            }
        }
        double v = 0;
        for (int l = 2; l <= numdata; l++) {
            double s1 = 0;
            double s2 = 0;
            double w = 0;
            for (int m = 1; m <= l; m++) {
                int i3 = l - m + 1;

                double val = transform.apply(list[i3 - 1]);

                s2 += val * val;
                s1 += val;

                w++;
                v = s2 - (s1 * s1) / w;
                int i4 = i3 - 1;
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

        int[] kclass = new int[numclass];

        kclass[numclass - 1] = list.length - 1;

        for (int j = numclass; j >= 2; j--) {
            int id = (int) (mat1[k][j]) - 2;

            kclass[j - 2] = id;

            k = (int) mat1[k][j] - 1;
        }
        return new Breaks(list, kclass);
    }

    private interface DoubleFunction {
           double apply(double x);
    }

    private static class Log10 implements DoubleFunction {

        @Override
        public double apply(double x) {
            return Math.log10(x);
        }
    }

    public static class Identity implements DoubleFunction {

        @Override
        public double apply(double x) {
            return x;
        }

    }

    public static class Breaks {

        private double[] sortedValues;
        private int[] breaks;

        private Breaks(double[] sortedValues, int[] breaks) {
            this.sortedValues = sortedValues;
            this.breaks = breaks;
        }

        public  double gvf() {
            double sdam = sumOfSquareDeviations(sortedValues);
            double sdcm = 0.0;
            for (int i = 0; i != numClassses(); ++i) {
                sdcm += sumOfSquareDeviations(classList(i));
            }
            return (sdam - sdcm) / sdam;
        }

        private  double sumOfSquareDeviations(double[] values) {
            double mean = mean(values);
            double sum = 0.0;
            for (int i = 0; i != values.length; ++i) {
                double sqDev = Math.pow(values[i] - mean, 2);
                sum += sqDev;
            }
            return sum;
        }

        public  double[] getValues() {
            return sortedValues;
        }

        private  double[] classList(int i) {
            int classStart = (i == 0) ? 0 : breaks[i - 1] + 1;
            int classEnd = breaks[i];
            double list[] = new double[classEnd - classStart + 1];
            for (int j = classStart; j <= classEnd; ++j) {
                list[j - classStart] = sortedValues[j];
            }
            return list;
        }

        public  double getClassMin(int classIndex) {
            if (classIndex == 0) {
                return sortedValues[0];
            } else {
                return sortedValues[breaks[classIndex - 1] + 1];
            }
        }

        public  double getClassMax(int classIndex) {
            return sortedValues[breaks[classIndex]];
        }

        public  int getClassCount(int classIndex) {
            if (classIndex == 0) {
                return breaks[0] + 1;
            } else {
                return breaks[classIndex] - breaks[classIndex - 1];
            }
        }

        private  double mean(double[] values) {
            double sum = 0;
            for (int i = 0; i != values.length; ++i) {
                sum += values[i];
            }
            return sum / values.length;
        }

        public  int numClassses() {
            return breaks.length;
        }

        @Override
        public  String toString() {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i != numClassses(); ++i) {
                if (getClassMin(i) == getClassMax(i)) {
                    sb.append(getClassMin(i));
                } else {
                    sb.append(getClassMin(i)).append(" - ").append(getClassMax(i));
                }
                sb.append(" (" + getClassCount(i) + ")");
                sb.append(" = ").append(Arrays.toString(classList(i)));
                sb.append("\n");
            }
            return sb.toString();
        }
        
        public int classOf(double value) {
            for (int i = 0; i != numClassses(); ++i) {
                if (value <= getClassMax(i)) {
                    return i;
                }
            }
            return numClassses() - 1;
        }
        
    	public static void main(String[] args) {
    		Jenks jenks = new Jenks();
    		jenks.addValue(1.0);
    		jenks.addValue(2.0);
    		jenks.addValue(2.0);
    		jenks.addValue(2.0);
    		jenks.addValue(3.0);
    	}
    	
    }
}