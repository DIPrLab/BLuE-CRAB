import 'package:flutter/material.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/styles/themes.dart';

class FilterButtonBar extends StatefulWidget {
  final VoidCallback? notify;

  FilterButtonBar({super.key, this.notify});

  @override
  FilterButtonBarState createState() => FilterButtonBarState();
}

class FilterButtonBarState extends State<FilterButtonBar> {
  late List<WidgetButtonProperties> filterButtons;

  @override
  void initState() {
    super.initState();
    filterButtons = [
      WidgetButtonProperties("Time w/ User", () => Settings.shared.enableTimeWithUserMetric, () {
        Settings.shared.enableTimeWithUserMetric = !Settings.shared.enableTimeWithUserMetric;
        widget.notify?.call();
      }),
      WidgetButtonProperties("Areas", () => Settings.shared.enableAreasMetric, () {
        Settings.shared.enableAreasMetric = !Settings.shared.enableAreasMetric;
        widget.notify?.call();
      }),
      WidgetButtonProperties("Distance w/ User", () => Settings.shared.enableDistanceWithUserMetric, () {
        Settings.shared.enableDistanceWithUserMetric = !Settings.shared.enableDistanceWithUserMetric;
        widget.notify?.call();
      }),
      WidgetButtonProperties("Incidence", () => Settings.shared.enableIncidenceMetric, () {
        Settings.shared.enableIncidenceMetric = !Settings.shared.enableIncidenceMetric;
        widget.notify?.call();
      }),
      WidgetButtonProperties("Proximity", () => Settings.shared.enableRSSIMetric, () {
        Settings.shared.enableRSSIMetric = !Settings.shared.enableRSSIMetric;
        widget.notify?.call();
      }),
    ];
    reorder([]);
  }

  void reorder(List<WidgetButtonProperties> propList) {
    propList.forEach((props) {
      filterButtons.remove(props);
      filterButtons.insert(0, props);
    });
    filterButtons.sort((a, b) => (a.value() && b.value()) || !(a.value() || b.value())
        ? 0
        : a.value()
            ? -1
            : 1);
  }

  Widget filterButton(WidgetButtonProperties props) => TextButton(
      child: Text(props.label, style: TextStyle(color: Colors.white)),
      onPressed: () => setState(() {
            props.onPressed();
            Settings.shared.save();
            reorder([props]);
          }),
      style: TextButton.styleFrom(
          backgroundColor: props.value() ? colors.altText : colors.background,
          enableFeedback: true,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), side: const BorderSide(color: colors.altText, width: 2.0))));

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
              children: filterButtons
                  .map((props) => filterButton(props))
                  .expand((e) => e != filterButtons.last ? [e, SizedBox(width: 12.0)] : [e])
                  .toList())));
}

class WidgetButtonProperties {
  final String label;
  final VoidCallback onPressed;
  bool Function() value;

  WidgetButtonProperties(this.label, this.value, this.onPressed);
}
