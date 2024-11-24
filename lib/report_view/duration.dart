extension PrintFriendly on Duration {
  String printFriendly() {
    List<String> result = [];
    Duration d = this;

    if (d.inDays > 0) {
      result.add("${d.inDays} days");
      d -= Duration(days: d.inDays);
    }

    if (d.inHours > 0) {
      result.add("${d.inHours} hrs");
      d -= Duration(hours: d.inHours);
    }

    if (d.inMinutes > 0) {
      result.add("${d.inMinutes} mins");
      d -= Duration(minutes: d.inMinutes);
    }

    if (d.inSeconds > 0) {
      result.add("${d.inSeconds} sec");
      d -= Duration(seconds: d.inSeconds);
    }

    return result.isEmpty ? "< 1 sec" : result.join(", ");
  }
}
