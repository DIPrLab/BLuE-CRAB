part of "settings_view.dart";

extension SettingsSlider on SettingsViewState {
  Column settingsSlider(String label, String valueLabel, double minValue, double maxValue, double value,
          void Function(double) onChange) =>
      Column(children: [
        Row(children: [Text(label), const Spacer(), Text(valueLabel)]),
        Slider(
            min: minValue,
            max: maxValue,
            value: value,
            onChanged: (newValue) => setState(() => onChange(newValue)),
            onChangeEnd: (value) => Settings.shared.save())
      ]);
}
