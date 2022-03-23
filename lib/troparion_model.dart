import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'dart:io';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'file_download.dart';
import 'globals.dart';
import 'saint_troparion.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;
  String? url;

  Troparion.fromMap(Map<String, Object?> data) {
    title = data["title"] as String;
    content = data["content"] as String;
    glas = data["glas"] as String;
    url = data["url"] as String;
  }
}

class TroparionDayModel extends StatelessWidget {
  final DateTime date;
  final Cal cal;

  static Database? db;

  TroparionDayModel(this.date) : cal = Cal.fromDate(date);

  bool isAvailable() {
    if (date.isBetween(cal.d("palmSunday"), cal.pascha)) {
      return false;
    } else {
      return Cal.getGreatFeast(date).isEmpty;
    }
  }

  Future<List<Troparion>> fetch() async {
    int code;
    List<Troparion> result = [];

    db ??= await DB.open("tropari_day.sqlite", dirname: "${GlobalPath.documents}/tropari_day");

    if (date.isBetween(cal.pascha, cal.d("sunday2AfterPascha") - 1.days)) {
      code = 100;
    } else if (date.weekday == DateTime.sunday) {
      code = 10 + cal.getTone(date)!;
    } else {
      code = (date.weekday % 7) + 1;
    }

    List<Map<String, Object?>> data =
        await db!.query("tropari", columns: ["title", "url", "content"], where: "code=$code");

    for (final Map<String, Object?> row in data) {
      var rr = Map<String, Object?>.from(row);
      final url = rr["url"];
      if (url != null) rr["url"] = "${GlobalPath.documents}/tropari_day/$url.mp3";

      result.add(Troparion.fromMap(rr));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable()) return Container();

    String title;

    if (date.isBetween(cal.pascha, cal.d("sunday2AfterPascha") - 1.days)) {
      title = "Часы пасхальные";
    } else {
      title = "Тропарь и кондак дня";
    }

    if (File("${GlobalPath.documents}/tropari_day/tropari_day.sqlite").existsSync()) {
      return FutureBuilder<List<Troparion>>(
          future: fetch(),
          builder: (BuildContext context, AsyncSnapshot<List<Troparion>> snapshot) {
            if (snapshot.hasData) {
              final troparia = List<Troparion>.from(snapshot.data!);

              if (troparia.isNotEmpty) {
                return CustomListTile(
                    title: title, onTap: () => SaintTroparionView(troparia).push(context));
              }
            }

            return Container();
          });
    } else {
      return CustomListTile(
          title: "Тропарь и кондак дня",
          onTap: () => FileDownload("$pCloudURL/prayerbook/tropari_day.zip").show(context));
    }
  }
}
