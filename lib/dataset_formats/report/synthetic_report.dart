part of 'report.dart';

extension Synthetic on Report {
  Report syntheticReportAtTime(DateTime ts) => Report(Map.fromEntries(devices()
      .where((d) => d.dataPoints(testing: true).any((dp) => dp.time.isBefore(ts)))
      .map((d) => MapEntry(
          d.id,
          Device(d.id, d.name, d.platformName, d.manufacturer,
              dataPoints: d
                  .dataPoints(testing: true)
                  .where((dp) => dp.time.isBefore(ts) || dp.time == ts)
                  .toMap((e) => e.time, (e) => e))))));
}
