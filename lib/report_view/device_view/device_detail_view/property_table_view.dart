import 'package:blue_crab/extensions/date_time.dart';
import 'package:blue_crab/report/device/device.dart';
import 'package:blue_crab/report/report.dart';
import 'package:flutter/material.dart';

class PropertyTable extends StatelessWidget {
  const PropertyTable(this.device, this.report, {super.key});

  List<DataRow> get rows {
    final List<DataRow> rows = [dataRow("UUID", device.id)];
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
      dataRow("Duration Travelled", device.timeTravelled.toReadableString()),
      dataRow("Distance Travelled", "${device.distanceTravelled.round()} meters"),
      dataRow("Incidence", device.incidence.toString()),
    ].forEach(rows.add);
    return rows;
  }

  final Device device;
  final Report report;

  DataRow dataRow(String label, String value) => DataRow(cells: [
        DataCell(Text(label, softWrap: true)),
        DataCell(Text(value, softWrap: true, textAlign: TextAlign.right))
      ]);

  @override
  Widget build(BuildContext context) => DataTable(
      sortColumnIndex: 1, columns: const [DataColumn(label: Text("")), DataColumn(label: Text(""))], rows: rows);
}
