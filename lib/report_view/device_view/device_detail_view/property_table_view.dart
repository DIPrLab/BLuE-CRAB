import 'package:blue_crab/extensions/date_time.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report_view/duration.dart';
import 'package:flutter/material.dart';

class PropertyTable extends StatelessWidget {
  PropertyTable(this.device, this.report, {super.key}) {
    rows.add(dataRow("UUID", device.id));
    if (device.name.isNotEmpty) {
      rows.add(dataRow("Name", device.name));
    }
    if (device.platformName.isNotEmpty) {
      rows.add(dataRow("Platform", device.platformName));
    }
    if (device.manufacturer.isNotEmpty) {
      rows.add(dataRow("Manufacturer", device.manufacturers().join(", ")));
    }
    [
      dataRow("Time Travelled", device.timeTravelled.toReadableString()),
      dataRow("Distance Travelled", "${device.distanceTravelled.round()} meters"),
      dataRow("Incidence", device.incidence.toString()),
      dataRow("Areas", device.areas.length.toString()),
      dataRow("Duration", device.timeTravelled.printFriendly())
    ].forEach(rows.add);
  }

  final Device device;
  final Report report;
  List<DataRow> rows = [];

  DataRow dataRow(String label, String value) => DataRow(cells: [
        DataCell(Text(label, softWrap: true)),
        DataCell(Text(value, softWrap: true, textAlign: TextAlign.right))
      ]);

  @override
  Widget build(BuildContext context) => DataTable(
      sortColumnIndex: 1, columns: const [DataColumn(label: Text("")), DataColumn(label: Text(""))], rows: rows);
}
