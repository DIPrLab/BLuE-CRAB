import 'package:flutter/material.dart';
import 'package:blue_crab/settings.dart';
import 'package:blue_crab/styles/themes.dart';

class FilterButtonBar extends StatefulWidget {
  FilterButtonBar(Settings this.settings, {super.key});

  final Settings settings;

  @override
  FilterButtonBarState createState() => FilterButtonBarState();
}

class FilterButtonBarState extends State<FilterButtonBar> {
  late List<WidgetButtonProperties> filterButtons;

  @override
  void initState() {
    super.initState();
    filterButtons = [
      WidgetButtonProperties("Time w/ User", () => widget.settings.enableTimeWithUserMetric,
          () => widget.settings.enableTimeWithUserMetric = !widget.settings.enableTimeWithUserMetric),
      WidgetButtonProperties("Areas", () => widget.settings.enableAreasMetric,
          () => widget.settings.enableAreasMetric = !widget.settings.enableAreasMetric),
      WidgetButtonProperties("Distance w/ User", () => widget.settings.enableDistanceWithUserMetric,
          () => widget.settings.enableDistanceWithUserMetric = !widget.settings.enableDistanceWithUserMetric),
      WidgetButtonProperties("Incidence", () => widget.settings.enableIncidenceMetric,
          () => widget.settings.enableIncidenceMetric = !widget.settings.enableIncidenceMetric),
      WidgetButtonProperties("Proximity", () => widget.settings.enableRSSIMetric,
          () => widget.settings.enableRSSIMetric = !widget.settings.enableRSSIMetric),
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

  Widget filterButton(WidgetButtonProperties props, Settings settings) => TextButton(
      child: Text(props.label, style: TextStyle(color: Colors.white)),
      onPressed: () => setState(() {
            props.onPressed();
            widget.settings.save();
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
                  .map((props) => filterButton(props, widget.settings))
                  .expand((e) => e != filterButtons.last ? [e, SizedBox(width: 12.0)] : [e])
                  .toList())));
}

class WidgetButtonProperties {
  final String label;
  final VoidCallback onPressed;
  bool Function() value;

  WidgetButtonProperties(this.label, this.value, this.onPressed);
}
