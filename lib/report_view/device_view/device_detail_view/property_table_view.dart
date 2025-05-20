import 'package:blue_crab/extensions/date_time.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/duration.dart';
import 'package:flutter/material.dart';

class PropertyTable extends StatelessWidget {
  PropertyTable(this.device, this.report, {super.key}) {
    rows.add(Row("UUID", device.id));
    if (device.name.isNotEmpty) {
      rows.add(Row("Name", device.name));
    }
    if (device.platformName.isNotEmpty) {
      rows.add(Row("Platform", device.platformName));
    }
    if (device.manufacturer.isNotEmpty) {
      rows.add(Row("Manufacturer", device.manufacturers().join(", ")));
    }
    [
      Row("Time Travelled", device.timeTravelled.toReadableString()),
      Row("Distance Travelled", "${device.distanceTravelled.round()} meters"),
      Row("Incidence", device.incidence.toString()),
      Row("Areas", device.areas.length.toString()),
      Row("Duration", device.timeTravelled.printFriendly())
    ].forEach(rows.add);
  }

  final Device device;
  final Report report;
  List<DataRow> rows = [];

  DataRow Row(String label, String value) => DataRow(cells: [
        DataCell(Text(label, softWrap: true)),
        DataCell(Text(value, softWrap: true, textAlign: TextAlign.right))
      ]);

  @override
  Widget build(BuildContext context) => DataTable(
      sortColumnIndex: 1, columns: const [DataColumn(label: Text("")), DataColumn(label: Text(""))], rows: rows);
}
