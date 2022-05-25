import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _getLocale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

extension DateTimeExt on DateTime {
  String formattedTime(BuildContext context) {
    return DateFormat.Hm(_getLocale(context)).format(this);
  }

  String formattedTimeDate(BuildContext context) {
    return DateFormat('HH:mm dd.MM.yyyy', _getLocale(context)).format(this);
  }

  String formattedDateShort(BuildContext context) {
    return DateFormat.yMd(_getLocale(context)).format(this);
  }

  String formattedDate(BuildContext context) {
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
