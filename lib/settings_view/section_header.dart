part of "settings_view.dart";

extension Headers on SettingsViewState {
  Widget headerNoPadding(String label) => Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget header(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
}
