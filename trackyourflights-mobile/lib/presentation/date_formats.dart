import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _getLocale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

extension DateTimeExt on DateTime {
  String formattedTime(BuildContext context) {
    return DateFormat.Hm(_getLocale(context)).format(this);
  }

  String formattedDate(BuildContext context) {
    return DateFormat.yMMMd(_getLocale(context)).format(this);
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
