
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';

import 'globals.dart';
import 'church_day.dart';

class ChurchCalendar {
  late int year;
  late List<ChurchDay> days;

  static Map<int, ChurchCalendar> calendars = {};

  factory ChurchCalendar.fromDate(DateTime d) {
    var year = d.year;

    if (!ChurchCalendar.calendars.containsKey(year)) {
      ChurchCalendar.calendars[year] = ChurchCalendar(d);
    }

    return ChurchCalendar.calendars[year]!;
  }

  ChurchCalendar(DateTime d) {
    year = d.year;
    JSON.dateParser = dateParser;

    initDays();
  }

  DateTime? dateParser(String date) {
    if (date != null) {
      var dd = DateFormat("d MMMM").parse(date);
      return DateTime(year, dd.month, dd.day);
    }
    else {
      return null;
    }
  }

  void initDays() {
    List<dynamic> parsed = jsonDecode(JSON.calendar);

    days = List<ChurchDay>.from(parsed.map((i) => ChurchDay.fromJson(i)));

    log(days.toString());
  }


}
