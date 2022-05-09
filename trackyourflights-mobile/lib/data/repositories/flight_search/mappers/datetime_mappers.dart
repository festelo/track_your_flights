abstract class DateTimeMappers {
  static DateTime dateTimeFromEpoch(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  static DateTime? dateTimeFromEpochNullable(int? seconds) {
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
