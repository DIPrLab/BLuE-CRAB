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

    devices = widget.report
        .devices()
        .where((device) => widget.report.riskScore(device!, widget.settings) > 0)
        .sorted((a, b) =>
            widget.report.riskScore(a!, widget.settings).compareTo(widget.report.riskScore(b!, widget.settings)))
        .reversed
        .toList();
  }

  void sortByTime() {
    setState(() {
      devices = widget.report
          .devices()
          .where((device) => widget.report.riskScore(device!, widget.settings) > 0)
          .sorted((a, b) {
            int threshold = widget.settings.thresholdTime.toInt();
            Duration deviceAValue = a!.timeTravelled(threshold);
            Duration deviceBValue = b!.timeTravelled(threshold);
            return deviceAValue.compareTo(deviceBValue);
          })
          .reversed
          .toList();
    });
  }

  void sortByIncidence() {
    setState(() {
      devices = widget.report
          .devices()
          .where((device) => widget.report.riskScore(device!, widget.settings) > 0)
          .sorted((a, b) {
            int threshold = widget.settings.thresholdTime.toInt();
            int deviceAValue = a!.incidence(threshold);
            int deviceBValue = b!.incidence(threshold);
            return deviceAValue.compareTo(deviceBValue);
          })
          .reversed
          .toList();
    });
  }

  void sortByLocation() {
    setState(() {
      devices = widget.report
          .devices()
          .where((device) => widget.report.riskScore(device!, widget.settings) > 0)
          .sorted((a, b) {
            int deviceAValue = a!.locations().length;
            int deviceBValue = b!.locations().length;
            return deviceAValue.compareTo(deviceBValue);
          })
          .reversed
          .toList();
    });
  }

  void sortByRisk() {
    setState(() {
      devices = widget.report
          .devices()
          .where((device) => widget.report.riskScore(device!, widget.settings) > 0)
          .sorted((a, b) {
            num deviceAValue = widget.report.riskScore(a!, widget.settings);
            num deviceBValue = widget.report.riskScore(b!, widget.settings);
            return deviceAValue.compareTo(deviceBValue);
          })
          .reversed
          .toList();
    });
  }

  Widget sortButton() {
    return PopupMenuButton<Null>(
      icon: const Icon(
        Icons.sort,
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort By Risk', style: TextStyles.normal),
          ),
          onTap: (() {
            setState(() {
              sortByRisk();
            });
          }),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort By Incidence', style: TextStyles.normal),
          ),
          onTap: (() {
            sortByIncidence();
          }),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort By Location', style: TextStyles.normal),
          ),
          onTap: (() {
            setState(() {
              sortByLocation();
            });
          }),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text('Sort By Time', style: TextStyles.normal),
          ),
          onTap: (() {
            setState(() {
              sortByTime();
            });
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(children: [
                Row(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text("Report", textAlign: TextAlign.center, style: TextStyles.title),
                    ),
                    const Spacer(),
                  ],
                ),
                BackButton(
                  onPressed: () => Navigator.pop(context),
                  style: AppButtonStyle.buttonWithoutBackground,
                ),
                Row(
                  children: [Spacer(), sortButton()],
                )
              ])),
          Column(
            children: [
              ...devices.map((device) => DeviceView(device!, widget.settings, report: widget.report)),
            ],
          ),
        ],
      ),
    ));
  }
}
