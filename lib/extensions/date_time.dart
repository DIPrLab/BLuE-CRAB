extension S on Duration {
  String toReadableString() => [
        "$inDays days",
        "${(this - Duration(days: inDays)).inHours} hours",
        "${(this - Duration(hours: inHours)).inMinutes} minutes",
        "${(this - Duration(minutes: inMinutes)).inSeconds} seconds"
      ].where((s) => s[0] != "0").join(", ");
}
