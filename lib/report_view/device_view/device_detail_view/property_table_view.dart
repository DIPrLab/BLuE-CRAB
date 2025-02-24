import 'package:blue_crab/report_view/duration.dart';
import 'package:flutter/material.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/report/report.dart';

class PropertyTable extends StatelessWidget {
  final Device device;
  final Report report;
  final Settings settings;
  List<DataRow> rows = [];

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
    rows.add(Row("Risk Score", report.riskScore(device, settings).toString()));
    rows.add(Row("Time Travelled", device.timeTravelled.toString()));
    rows.add(Row("Distance Travelled", device.distanceTravelled.toString()));
    rows.add(Row("Incidence", device.incidence.toString()));
    rows.add(Row("Areas", device.areas.length.toString()));
    rows.add(Row("Duration", device.timeTravelled.printFriendly()));
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
