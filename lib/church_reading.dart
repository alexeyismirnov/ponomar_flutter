import 'package:supercharged/supercharged.dart';

import 'dart:convert';

import 'church_calendar.dart';
import 'globals.dart';

class LukeSpringParams {
  late DateTime PAPSunday;
  late DateTime pentecostPrevYear;
  late DateTime sundayAfterExaltationPrevYear;
  late int totalOffset;

  LukeSpringParams(Cal cal) {
    PAPSunday = cal.d("sundayOfPublicianAndPharisee");
    pentecostPrevYear = Cal.paschaDay(cal.year - 1) + 50.days;

    var exaltationPrevYear = DateTime(cal.year - 1, 9, 27);
    var exaltationPrevYearWeekday = exaltationPrevYear.weekday;

    sundayAfterExaltationPrevYear = exaltationPrevYear + (8 - exaltationPrevYearWeekday).days;
    var endOfLukeReadings = sundayAfterExaltationPrevYear + 112.days;
    totalOffset = endOfLukeReadings >> PAPSunday;
  }
}

class ChurchReading {
  late Cal cal;
  late LukeSpringParams LS;
  Map<DateTime, List<String>> rr = {};
  late List<String> apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent;

  static Map<int, ChurchReading> models = {};

  ChurchReading(DateTime d) {
    cal = Cal.fromDate(d);
    LS = LukeSpringParams(cal);

    apostle = List<String>.from(json.decode(JSON.apostle));
    readingsJohn = List<String>.from(json.decode(JSON.readingsJohn));
    gospelMatthew = List<String>.from(json.decode(JSON.gospelMatthew));
    gospelLuke = List<String>.from(json.decode(JSON.gospelLuke));
    readingsLent = List<String>.from(json.decode(JSON.readingsLent));
  }

  String GospelOfLent(DateTime date) {
    final dayNum = cal.d("sundayOfPublicianAndPharisee") >> date;
    return readingsLent[dayNum];
  }

  String GospelOfJohn(DateTime date) {
    final dayNum = cal.pascha >> date;
    return readingsJohn[dayNum];
  }

  String GospelOfMatthew(DateTime date) {
    var dayNum = (cal.pentecost + 1.days) >> date;
    var readings = apostle[dayNum] + " ";

    if (dayNum >= 17 * 7) dayNum = dayNum - 7 * 7;

    readings += gospelMatthew[dayNum];
    return readings;
  }

  String GospelOfLukeSpring(DateTime date) {
    int gospelIndex, apostleIndex;

    final daysFromPentecost = LS.pentecostPrevYear >> date;
    final daysFromExaltation = (LS.sundayAfterExaltationPrevYear + 1.days) >> date;
    final daysBeforePAP = date >> LS.PAPSunday;

    if (daysFromExaltation >= 16 * 7 - 1) {
      // need more than three additional Sundays, use 17th week Matthew readings
      if (LS.totalOffset > 28) {
        if (daysBeforePAP < 21 && daysBeforePAP >= 14) {
          final indexMatthew = 118 - (daysBeforePAP - 14);
          return apostle[indexMatthew] + " " + gospelMatthew[indexMatthew];
        } else if (daysBeforePAP >= 21) {
          gospelIndex = 118 - daysBeforePAP;
          apostleIndex = 237 - daysBeforePAP;
          return apostle[apostleIndex] + " " + gospelLuke[gospelIndex];
        }
      }

      gospelIndex = 111 - daysBeforePAP;
      apostleIndex = 230 - daysBeforePAP;
    } else if (daysFromPentecost >= 33 * 7 - 1) {
      gospelIndex = daysFromExaltation;
      apostleIndex = 230 - daysBeforePAP;
    } else {
      gospelIndex = daysFromExaltation;
      apostleIndex = daysFromPentecost;
    }

    return apostle[apostleIndex] + " " + gospelLuke[gospelIndex];
  }

  String GospelOfLukeFall(DateTime date) {
    if (date == cal.d("sundayOfForefathers")) {
      return apostle[202] + " " + gospelLuke[76];
    }

    var daysFromPentecost = (cal.pentecost + 1.days) >> date;
    var daysFromLukeStart = (cal.d("sundayAfterExaltation") + 1.days) >> date;

    // On 29th Sunday borrow Epistle from Sunday of Forefathers
    if (daysFromPentecost == 202) {
      daysFromPentecost = (cal.pentecost + 1.days) >> cal.d("sundayOfForefathers");
    }

    // On 28th Sunday borrow Gospel from Sunday of Forefathers
    if (daysFromLukeStart == 76) {
      daysFromLukeStart = (cal.d("sundayAfterExaltation") + 1.days) >> cal.d("sundayOfForefathers");
    }

    return apostle[daysFromPentecost] + " " + gospelLuke[daysFromLukeStart];
  }

  String? getRegularReading(DateTime date) {
    if (date.isBetween(cal.startOfYear, cal.d("sundayOfPublicianAndPharisee") - 1.days)) {
      return GospelOfLukeSpring(date);
    } else if (date.isBetween(cal.d("sundayOfPublicianAndPharisee"), cal.pascha - 1.days)) {
      final reading = GospelOfLent(date);
      return reading.isNotEmpty ? reading : null;
    } else if (date.isBetween(cal.pascha, cal.pentecost)) {
      return GospelOfJohn(date);
    } else if (date.isBetween(cal.pentecost + 1.days, cal.d("sundayAfterExaltation"))) {
      return GospelOfMatthew(date);
    } else if (date.isBetween(cal.d("sundayAfterExaltation") + 1.days, cal.endOfYear)) {
      return GospelOfLukeFall(date);
    } else {
      return null;
    }
  }

  List<String> getDailyReading(DateTime date) {
    return [];
  }

  static List<String> forDate(DateTime date) {
    if (!models.containsKey(date.year)) {
      models[date.year] = ChurchReading(date);
    }

    return models[date.year]!.getDailyReading(date);
  }
}
