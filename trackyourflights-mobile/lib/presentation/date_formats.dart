import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String? _getLocale(BuildContext? context) =>
    context == null ? null : Localizations.localeOf(context).toLanguageTag();

extension DateTimeExt on DateTime {
  String formattedTime(BuildContext? context) {
    return DateFormat.Hm(_getLocale(context)).format(this);
  }

  String formattedTimeDate(BuildContext? context) {
    return DateFormat('HH:mm dd.MM.yyyy', _getLocale(context)).format(this);
  }

  String formattedDateTimeTz(BuildContext? context) {
    final dateTime = toLocal();
    final dateTimeString =
        DateFormat('dd.MM.yyyy HH:mm', _getLocale(context)).format(dateTime);
    final tzString = dateTime.formatTzOffset();
    return '$dateTimeString ($tzString)';
  }

  String formatTzOffset() {
    String twoDigits(int n) => n >= 10 ? "$n" : "0$n";

    var hours = twoDigits(timeZoneOffset.inHours.abs());
    var minutes = twoDigits(timeZoneOffset.inMinutes.remainder(60));
    var sign = timeZoneOffset.inHours > 0 ? "+" : "-";

    return "$sign$hours:$minutes";
  }

  String formattedDateShort(BuildContext? context) {
    return DateFormat.yMd(_getLocale(context)).format(this);
  }

  String formattedDate(BuildContext? context) {
    return DateFormat.yMMMd(_getLocale(context)).format(this);
  }
}

extension DurationExt on Duration {
  String formattedTime(BuildContext context) {
    return "${inHours.toString().padLeft(2, '0')}:${inMinutes.remainder(60).toString().padLeft(2, '0')}";
  }
}

class DateTimeParser {
  static DateTime? time(BuildContext context, String? s) {
    if (s == null) return null;
    try {
      return DateFormat.Hm(_getLocale(context)).parse(s);
    } catch (e) {
      return null;
    }
  }
}
