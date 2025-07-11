part of 'package:blue_crab/testing_suite/testing_suite.dart';

extension FlaggedDevicesAtTime on TestingSuite {
  CSVData getFlaggedDevicesAtTime(Report report, Set<String> gt) {
    final CSVData csv = CSVData([
      "MINUTES_SINCE_INIT",
      "NUMBER_OF_SUSPICIOUS_DEVICES",
      "NUMBER_OF_DEVICES_TO_FLAG",
      "NUMBER_OF_DEVICES_TO_UNFLAG",
      "TRUE_POSITIVES",
      "FALSE_POSITIVES",
      "TRUE_NEGATIVES",
      "FALSE_NEGATIVES",
      "TRUE_POSITIVES_RATE",
      "FALSE_POSITIVES_RATE",
      "TRUE_NEGATIVES_RATE",
      "FALSE_NEGATIVES_RATE",
      "POSITIVES_ACCURACY",
      "NEGATIVES_ACCURACY",
      "OVERALL_ACCURACY",
      "F1_SCORE",
    ]);
    Set<String> devicesToFlag = {};
    Set<String> devicesToUnflag = {};
    final Set<String> flaggedDevices = {};
    final List<DateTime> timeStamps = report.getTimestamps();
    generateTimestamps(timeStamps).forEach((ts) {
      final Report r = report.syntheticReportAtTime(ts);
      if (r.devices().length < 2) {
        return;
      }
      r.refreshCache();

      // Get all suspicious devices not currently flagged and add them to flagged devices
      devicesToFlag = r.getSuspiciousDeviceIDs().where((d) => !flaggedDevices.contains(d)).toSet();
      flaggedDevices.addAll(devicesToFlag);

      // Get all non-suspicious devices currently flagged and remove them to flagged devices
      devicesToUnflag = r.deviceIDs().difference(r.getSuspiciousDeviceIDs()).where(flaggedDevices.contains).toSet();
      flaggedDevices.removeAll(devicesToUnflag);

      final double accuracy = (flaggedDevices.intersection(gt).length +
              r.deviceIDs().difference(flaggedDevices).intersection(r.deviceIDs().difference(gt)).length) /
          r.deviceIDs().length;
      final double recall = flaggedDevices.intersection(gt).length /
          (flaggedDevices.intersection(gt).length +
              r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length);
      final double precision = flaggedDevices.intersection(gt).length /
          (flaggedDevices.intersection(gt).length + flaggedDevices.difference(gt).length);
      final double f1 = 2 * ((precision * recall) / (precision + recall));

      csv.addRow([
        // Time since starting scan
        ts.difference(timeStamps.first).inMinutes,
        // Number of suspicious devices
        flaggedDevices.length,
        // Number of devices to flag
        devicesToFlag.length,
        // Number of devices to un-flag
        devicesToUnflag.length,
        // True positives
        flaggedDevices.intersection(gt).length,
        // False positives
        flaggedDevices.difference(gt).length,
        // True negatives
        r.deviceIDs().difference(flaggedDevices).intersection(r.deviceIDs().difference(gt)).length,
        // False negatives
        r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length,
        // True positive rate
        flaggedDevices.intersection(gt).length / r.deviceIDs().length,
        // False positive rate
        flaggedDevices.difference(gt).length / r.deviceIDs().length,
        // True negative rate
        r.deviceIDs().difference(flaggedDevices).intersection(r.deviceIDs().difference(gt)).length /
            r.deviceIDs().length,
        // False negative rate
        r.deviceIDs().difference(flaggedDevices).difference(r.deviceIDs().difference(gt)).length / r.deviceIDs().length,
        // Positives accuracy
        flaggedDevices.intersection(gt).length / gt.length,
        // Negatives Accuracy
        r.deviceIDs().difference(gt).difference(flaggedDevices).length / r.deviceIDs().difference(gt).length,
        // Overall Accuracy
        accuracy,
        // F1 Score
        f1,
      ].map((e) => e.toString()).toList());
    });
    return csv;
  }
}
