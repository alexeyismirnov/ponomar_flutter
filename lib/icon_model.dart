import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'globals.dart';
import 'church_day.dart';
import 'church_calendar.dart';

class SaintIcon {
  final int id;
  final String name;
  final bool has_icon;

  SaintIcon(this.id, this.name, this.has_icon);
}

class IconModel {
  static late Database db;

  static Future prepare() async {
    await DB.prepare(basename: "assets/icons", filename: "icons.sqlite");
    db = await DB.open("icons.sqlite");
  }

  static Future<List<SaintIcon>> fetch(DateTime d) async {
    List<SaintIcon> saints = [];
    final year = d.year;
    final cal = ChurchCalendar.fromDate(d);

    if (cal.isLeapYear) {
    } else {
      saints.addAll(await _addSaints(d));
      if (d == cal.leapEnd) {
        saints.addAll(await _addSaints(DateTime(2000, 2, 29)));
      }
    }

    return saints;
  }

  static Future<List<SaintIcon>> _addSaints(DateTime d) async {
    List<SaintIcon> saints = [];
    final day = d.day;
    final month = d.month;

    List<Map<String, Object?>> data = await db.query("app_saint",
        columns: ["id", "name", "has_icon"], where: "month=$month AND day=$day AND has_icon=1");

    for (final Map<String, Object?> row in data) {
      saints.add(SaintIcon(row["id"] as int, row["name"] as String, (row["has_icon"] as int) == 1));
    }

    List<Map<String, Object?>> links = await db.query("app_saint JOIN link_saint",
        columns: [
          "link_saint.name AS name",
          "app_saint.id AS id",
          "app_saint.has_icon AS has_icon"
        ],
        where:
            "link_saint.month=$month AND link_saint.day=$day AND app_saint.id = link_saint.id AND app_saint.has_icon=1");

    for (final Map<String, Object?> row in links) {
      saints.add(SaintIcon(row["id"] as int, row["name"] as String, (row["has_icon"] as int) == 1));
    }

    return saints;
  }
}
