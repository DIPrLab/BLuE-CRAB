extension S on Duration {
  String toReadableString() => [
        this.inDays.toString() + " days",
        (this - Duration(days: this.inDays)).inHours.toString() + " hours",
        (this - Duration(hours: this.inHours)).inMinutes.toString() + " minutes",
        (this - Duration(minutes: this.inMinutes)).inSeconds.toString() + " seconds"
      ].where((s) => s[0] != "0").join(", ");
}
