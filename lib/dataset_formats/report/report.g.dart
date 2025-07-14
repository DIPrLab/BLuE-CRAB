part of 'report.dart';

Report _$ReportFromJson(Map<String, dynamic> json) {
  Report? report;
  try {
    report = CompactDataset.fromJson(json).toReport();
    Logger().i("Successfully loaded report as CompactDataset.");
  } catch (e) {
    try {
      report = BleDoubtReport.fromJson(json).toReport();
      Logger().i("Successfully loaded report as BleDoubtReport.");
    } catch (e) {
      Logger().w("Failed to load data. Generating empty report.");
    }
  }
  return report ?? Report({});
}
