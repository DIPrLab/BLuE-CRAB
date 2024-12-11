import 'package:bluetooth_detector/report_view/duration.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detector/report/device/device.dart';
import 'package:bluetooth_detector/settings.dart';
import 'package:bluetooth_detector/report/report.dart';

class PropertyTable extends StatelessWidget {
  final Device device;
  final Report report;
  final Settings settings;
  List<DataRow> rows = [];

  String printDistance(double m) => (m / 1000).toStringAsFixed(2) + " km";

  PropertyTable(this.device, this.report, this.settings, {super.key}) {
    rows.add(Row("UUID", device.id.toString()));
    if (!device.name.isEmpty) {
      rows.add(Row("Name", device.name));
    }
    if (!device.platformName.isEmpty) {
      rows.add(Row("Platform", device.platformName));
    }
    if (!device.manufacturer.isEmpty) {
      rows.add(Row("Manufacturer", device.manufacturers().join(", ")));
    }
    // rows.add(Row("Risk Score", report.riskScore(device, settings).toString()));
    rows.add(Row("Incidence", device.incidence.toString()));
    rows.add(Row("Areas", 1.toString()));
    rows.add(Row("Duration", device.timeTravelled.printFriendly()));
    rows.add(Row("Distance", printDistance(device.distanceTravelled)));
  }

  DataRow Row(String label, String value) => DataRow(cells: [
        DataCell(Text(label, softWrap: true)),
        DataCell(Text(value, softWrap: true, textAlign: TextAlign.right))
      ]);

  @override
  Widget build(context) => DataTable(
      sortAscending: true,
      sortColumnIndex: 1,
      showBottomBorder: false,
      columns: const [DataColumn(label: Text("")), DataColumn(label: Text(""))],
      rows: rows);
}
