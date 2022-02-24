import 'package:flutter/services.dart' show rootBundle;
import 'package:sprintf/sprintf.dart';
import 'package:flutter/cupertino.dart';

import 'package:easy_localization/easy_localization.dart';

class JSON {
  static late String calendar;
  static late Function(String) dateParser;

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
  }
}

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);
}

extension DateTimeDiff on DateTime {
  int operator >>(DateTime other) => other.difference(this).inDays;
}

extension LocaleContext on BuildContext {
  String get languageCode => EasyLocalization.of(this)!.locale.toString().split("_").first;
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class DateChangedNotification extends Notification {
  late DateTime newDate;
  DateChangedNotification(this.newDate) : super();
}
