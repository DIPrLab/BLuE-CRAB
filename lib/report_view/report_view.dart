import 'package:blue_crab/report_view/filter_buttons/filter_buttons.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:blue_crab/report_view/device_view/device_view.dart';
import 'package:blue_crab/report/report.dart';
import 'package:blue_crab/report/device/device.dart';

class ReportView extends StatefulWidget {
  ReportView({super.key, required this.report});

  final Report report;

  @override
  ReportViewState createState() => ReportViewState();
}

class ReportViewState extends State<ReportView> {
  late List<Device> devices;

  @override
  void initState() {
    super.initState();
    sort(byRiskScore);
  }

  void sort(int sortMethod(Device a, Device b)) => setState(() => devices = widget.report
      .devices()
      .where((device) => widget.report.riskScore(device) > widget.report.riskScoreStats.tukeyMildUpperLimit)
      .sorted(sortMethod)
      .reversed
      .toList());

  int byRiskScore(Device a, Device b) => widget.report.riskScore(a).compareTo(widget.report.riskScore(b));

  int byArea(Device a, Device b) => a.areas.length.compareTo(b.areas.length);

  int byTime(Device a, Device b) => a.timeTravelled.compareTo(b.timeTravelled);

  int byIncidence(Device a, Device b) => a.incidence.compareTo(b.incidence);

  int byLocation(Device a, Device b) => a.locations().length.compareTo(b.locations().length);

  Widget sortButton() => PopupMenuButton<dynamic>(
      icon: const Icon(Icons.sort),
      itemBuilder: (BuildContext context) => [
            ("Risk", byRiskScore),
            ("Incidence", byIncidence),
            ("Location", byLocation),
            ("Time", byTime),
            ("Areas", byArea),
          ]
              .map((e) => (ListTile(title: Text("Sort By ${e.$1}")), e.$2))
              .map((e) => PopupMenuItem(child: e.$1, onTap: () => sort(e.$2)))
              .toList());

  Widget header(BuildContext context) => Padding(
      padding: const EdgeInsets.all(4),
      child: Stack(children: [
        Row(children: [
          const Spacer(),
          Text("Report", textAlign: TextAlign.center, style: TextStyles.title),
          const Spacer(),
        ]),
        BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithoutBackground),
        Row(children: [Spacer(), sortButton()])
      ]));

  List<Widget> deviceTileList(BuildContext context) => devices
      .map((device) => DeviceView(device, report: widget.report))
      .map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), child: w))
      .toList();

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SingleChildScrollView(
              child: Column(children: [
        header(context),
        FilterButtonBar(),
        Column(children: deviceTileList(context)),
      ])));
}
