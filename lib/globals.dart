import 'package:flutter/services.dart' show rootBundle;

class JSON {
  static late String calendar;
  static late Function(String) dateParser;

  static Future load() async {
    calendar = await rootBundle.loadString("assets/calendar/calendar.json");
  }
}
