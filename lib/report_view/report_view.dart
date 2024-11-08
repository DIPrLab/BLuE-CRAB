import 'package:bluetooth_detector/styles/styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_detector/report_view/device_view/device_view.dart';
import 'package:bluetooth_detector/report/report.dart';
import 'package:bluetooth_detector/report/device.dart';
import 'package:bluetooth_detector/settings.dart';

class ReportView extends StatefulWidget {
  ReportView(Settings this.settings, {super.key, required this.report});

  final Report report;
  final Settings settings;

  @override
  ReportViewState createState() => ReportViewState();
}

class ReportViewState extends State<ReportView> {
  late List<Device?> devices;

  @override
  void initState() {
    super.initState();
    widget.report.refreshCache(widget.settings);
    sort(byRiskScore);
  }

  void sort(int sortMethod(Device a, Device b)) => setState(() => devices = widget.report
      .devices()
      .where((device) => device != null)
      .map((device) => device!)
      .where((device) => widget.report.riskScore(device, widget.settings) > 0)
      .sorted(sortMethod)
      .reversed
      .toList());

  int byRiskScore(Device a, Device b) {
    num deviceAValue = widget.report.riskScore(a, widget.settings);
    num deviceBValue = widget.report.riskScore(b, widget.settings);
    return deviceAValue.compareTo(deviceBValue);
  }

  int byTime(Device a, Device b) {
    Duration deviceAValue = a.timeTravelled(widget.settings.timeThreshold(), widget.settings.windowDuration());
    Duration deviceBValue = b.timeTravelled(widget.settings.timeThreshold(), widget.settings.windowDuration());
    return deviceAValue.compareTo(deviceBValue);
  }

  int byIncidence(Device a, Device b) {
    int deviceAValue = a.incidence(widget.settings.timeThreshold(), widget.settings.windowDuration());
    int deviceBValue = b.incidence(widget.settings.timeThreshold(), widget.settings.windowDuration());
    return deviceAValue.compareTo(deviceBValue);
  }

  int byLocation(Device a, Device b) {
    int deviceAValue = a.locations(widget.settings.windowDuration()).length;
    int deviceBValue = b.locations(widget.settings.windowDuration()).length;
    return deviceAValue.compareTo(deviceBValue);
  }

  Widget sortButton() => PopupMenuButton<Null>(
      icon: const Icon(Icons.sort),
      itemBuilder: (BuildContext context) => [
            PopupMenuItem(
                child: ListTile(title: Text('Sort By Risk', style: TextStyles.normal)),
                onTap: (() => sort(byRiskScore))),
            PopupMenuItem(
                child: ListTile(title: Text('Sort By Incidence', style: TextStyles.normal)),
                onTap: (() => sort(byIncidence))),
            PopupMenuItem(
                child: ListTile(title: Text('Sort By Location', style: TextStyles.normal)),
                onTap: (() => sort(byLocation))),
            PopupMenuItem(
                child: ListTile(title: Text('Sort By Time', style: TextStyles.normal)), onTap: (() => sort(byTime))),
          ]);

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SingleChildScrollView(
              child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(children: [
              Row(children: [
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text("Report", textAlign: TextAlign.center, style: TextStyles.title)),
                const Spacer(),
              ]),
              BackButton(onPressed: () => Navigator.pop(context), style: AppButtonStyle.buttonWithoutBackground),
              Row(children: [Spacer(), sortButton()])
            ])),
        Column(children: [...devices.map((device) => DeviceView(device!, widget.settings, report: widget.report))]),
      ])));
}
