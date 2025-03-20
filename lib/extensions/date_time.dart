extension S on Duration {
  String toReadableString() => [
        inDays.toString() + " days",
        (this - Duration(days: inDays)).inHours.toString() + " hours",
        (this - Duration(hours: inHours)).inMinutes.toString() + " minutes",
        (this - Duration(minutes: inMinutes)).inSeconds.toString() + " seconds"
      ].where((s) => s[0] != "0").join(", ");
}
