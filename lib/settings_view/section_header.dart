part of "settings_view.dart";

extension Headers on SettingsViewState {
  Widget headerNoPadding(String label) =>
      Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget header(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
}
