import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String _getLocale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  String formattedTime(BuildContext context) {
    return DateFormat.Hm(_getLocale(context)).format(this);
  }

  String formattedDate(BuildContext context) {
    return DateFormat.yMMMd(_getLocale(context)).format(this);
  }
}
