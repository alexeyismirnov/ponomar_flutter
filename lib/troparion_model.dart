import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'dart:io';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'file_download.dart';
import 'globals.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;
  String? url;

  Troparion.fromMap(Map<String, Object?> data) {
    title = data["title"] as String;
    content = data["content"] as String;
    glas = data["glas"] as String;
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

  Future<List<Troparion>> fetch(DateTime d) async {
    db ??= await DB.open("tropari_day.sqlite");

    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (!isAvailable()) return Container();

    if (File("${GlobalPath.documents}/tropari_day/tropari_day.sqlite").existsSync()) {
      return CustomListTile(title: "Тропарь и кондак дня", onTap: () => print("qq"));
    } else {
      return CustomListTile(
          title: "Тропарь и кондак дня",
          onTap: () => FileDownload("$pCloudURL/prayerbook/tropari_day.zip").show(context));
    }
  }
}
