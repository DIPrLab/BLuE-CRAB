import 'package:blue_crab/classifiers/classifier.dart';
import 'package:blue_crab/map_view/map_functions.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/settings_view/lat_lng_tile.dart';
import 'package:blue_crab/styles/styles.dart';
import 'package:flutter/material.dart';

part "section_header.dart";
part "slider.dart";

class LocationHeader extends StatelessWidget implements PreferredSizeWidget {
  const LocationHeader({required this.onAddLocation, super.key});
  final VoidCallback onAddLocation;

  @override
  Widget build(BuildContext context) => Center(
      child: ListTile(
          leading: IconButton(icon: const Icon(Icons.add), onPressed: onAddLocation),
          title: const Text("Add New Safe Zone")));

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.notify});

  final VoidCallback? notify;

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  void _addLocation() => getLocation().then((location) => setState(() {
        Settings.shared.recentlyChanged = true;
        Settings.shared.safeZones.add(location);
        Settings.shared.save();
      }));

  void changeClassifier(Classifier? c) => Settings.shared.classifier = c ?? Settings.shared.classifier;

  Column settingsDropdownMenu(
          String label, String valueLabel, List<num> values, num value, void Function(num) onChange) =>
      Column(children: [
        Row(children: [Text(label), const Spacer(), Text(valueLabel)]),
        DropdownButton(
            items: values.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
            value: value,
            onChanged: (newValue) {
              setState(() => onChange(newValue!));
              Settings.shared.save();
            })
      ]);

  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    BackButton(
                        onPressed: () {
                          Settings.shared.save();
                          Navigator.pop(context);
                        },
                        style: buttonWithoutBackground),
                    header("Classifier"),
                    DropdownButton<Classifier>(
                        value: Settings.shared.classifier,
                        items: Classifier.classifiers
                            .map((e) => DropdownMenuItem<Classifier>(value: e, child: Text(e.name())))
                            .toList(),
                        onChanged: (newValue) => setState(() => Settings.shared.classifier = newValue!)),
                    header("Thresholds"),
                    settingsSlider("Scanning Time Threshold", "${Settings.shared.timeThreshold().inSeconds} seconds", 1,
                        100, Settings.shared.timeThresholdValue, (newValue) {
                      Settings.shared.recentlyChanged = true;
                      Settings.shared.timeThresholdValue = newValue;
                      setState(() {});
                    }),
                    settingsSlider(
                        "Scanning Distance Threshold",
                        "${Settings.shared.distanceThreshold().toInt()} meters",
                        1,
                        100,
                        Settings.shared.distanceThresholdValue, (newValue) {
                      Settings.shared.recentlyChanged = true;
                      Settings.shared.distanceThresholdValue = newValue;
                      setState(() {});
                    }),
                    header("Safe Zones"),
                    LocationHeader(onAddLocation: _addLocation),
                    ...Settings.shared.safeZones.map(LatLngTile.new),
                    header("Mode"),
                    SwitchListTile(
                        title: Text("Data Collection Mode ${Settings.shared.dataCollectionMode ? "On" : "Off"}"),
                        value: Settings.shared.dataCollectionMode,
                        onChanged: (val) {
                          setState(() {
                            Settings.shared.dataCollectionMode = val;
                            if (val) {
                              Settings.shared.demoMode = false;
                              Settings.shared.devMode = false;
                            }
                          });
                          widget.notify?.call();
                          Settings.shared.save();
                        },
                        secondary:
                            Icon(Icons.circle, color: Settings.shared.dataCollectionMode ? Colors.green : Colors.red)),
                    SwitchListTile(
                        title: Text("Developer Mode ${Settings.shared.devMode ? "On" : "Off"}"),
                        value: Settings.shared.devMode,
                        onChanged: (val) {
                          setState(() {
                            Settings.shared.devMode = val;
                            if (val) {
                              Settings.shared.dataCollectionMode = false;
                              Settings.shared.demoMode = false;
                            }
                          });
                          widget.notify?.call();
                          Settings.shared.save();
                        },
                        secondary: Icon(Icons.circle, color: Settings.shared.devMode ? Colors.green : Colors.red)),
                    SwitchListTile(
                        title: Text("Demo Mode ${Settings.shared.demoMode ? "On" : "Off"}"),
                        value: Settings.shared.demoMode,
                        onChanged: (val) {
                          setState(() {
                            Settings.shared.demoMode = val;
                            if (val) {
                              Settings.shared.dataCollectionMode = false;
                              Settings.shared.devMode = false;
                            }
                          });
                          widget.notify?.call();
                          Settings.shared.save();
                        },
                        secondary: Icon(Icons.circle, color: Settings.shared.demoMode ? Colors.green : Colors.red)),
                  ])))));
}
