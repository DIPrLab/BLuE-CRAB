part of "settings_view.dart";

extension SettingsDropdownMenu on SettingsViewState {
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
}
