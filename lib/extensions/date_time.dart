extension S on Duration {
  String toReadableString() => inSeconds < 1
      ? "< 1 sec"
      : [
          "$inDays days",
          "${(this - Duration(days: inDays)).inHours} hrs",
          "${(this - Duration(hours: inHours)).inMinutes} mins",
          "${(this - Duration(minutes: inMinutes)).inSeconds} sec"
        ].where((s) => s[0] != "0").join(", ");
}
