import 'package:flutter/services.dart' show rootBundle;
import 'package:sprintf/sprintf.dart';
import 'package:flutter/cupertino.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:core';
import 'dart:async';
import 'dart:convert';

import 'book_model.dart';

class JSON {
  static late String calendar;
  static late String apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent;
  static late Function(String) dateParser;

  static late String OldTestamentItems, OldTestamentFilenames;
  static late String NewTestamentItems, NewTestamentFilenames;

  static Map<String, Map<String, String>> bibleTrans = {};

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
    apostle = await rootBundle.loadString("assets/calendar/ReadingApostle.json");
    readingsJohn = await rootBundle.loadString("assets/calendar/ReadingJohn.json");
    gospelMatthew = await rootBundle.loadString("assets/calendar/ReadingMatthew.json");
    gospelLuke = await rootBundle.loadString("assets/calendar/ReadingLuke.json");
    readingsLent = await rootBundle.loadString("assets/calendar/ReadingLent.json");

    OldTestamentItems = await rootBundle.loadString("assets/bible/OldTestamentItems.json");
    OldTestamentFilenames = await rootBundle.loadString("assets/bible/OldTestamentFilenames.json");
    NewTestamentItems = await rootBundle.loadString("assets/bible/NewTestamentItems.json");
    NewTestamentFilenames = await rootBundle.loadString("assets/bible/NewTestamentFilenames.json");

    bibleTrans['en'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/en/reading.json")));
    bibleTrans['ru'] = Map<String, String>.from(
        jsonDecode(await rootBundle.loadString("assets/translations/ru/reading.json")));
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

class BookPositionNotification extends Notification {
  late BookPosition pos;
  BookPositionNotification(this.pos) : super();
}

extension ConfigParamExt on ConfigParam {
  static var fastingLevel;
}
