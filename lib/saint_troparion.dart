import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

import 'troparion_model.dart';
import 'church_calendar.dart';
import 'book_page_single.dart';
import 'audio_player.dart';

class SaintTroparionModel {
  static Database? db;

  static Future<List<Troparion>> fetch(DateTime d) async {
    List<Troparion> saints = [];
    var cal = Cal.fromDate(d);

    if (cal.isLeapYear) {
      if (d.isBetween(cal.leapStart, cal.leapEnd - 1.days)) {
        saints = await _saintData(d + 1.days);
      } else if (d == cal.leapEnd) {
        saints = await _saintData(DateTime(cal.year, 2, 29));
      } else {
        saints = await _saintData(d);
      }
    } else {
      saints = await _saintData(d);
      if (d == cal.leapEnd) {
        saints.addAll(await _saintData(DateTime(2000, 2, 29)));
      }
    }

    return saints;
  }

  static Future<List<Troparion>> _saintData(DateTime d) async {
    List<Troparion> result = [];

    db ??= await DB.open("troparion.sqlite");

    List<Map<String, Object?>> data = await db!.query("tropari",
        columns: ["title", "glas", "content"], where: "day=${d.day} AND month=${d.month}");

    for (final Map<String, Object?> row in data) {
      result.add(Troparion.fromMap(row));
    }

    return result;
  }
}

class SaintTroparionView extends StatefulWidget {
  final List<Troparion> troparia;
  const SaintTroparionView(this.troparia);

  @override
  _SaintTroparionViewState createState() => _SaintTroparionViewState();
}

class _SaintTroparionViewState extends State<SaintTroparionView> {
  String title = "Тропари и кондаки";

  late double fontSize;

  @override
  void initState() {
    super.initState();

    fontSize = ConfigParam.fontSize.val();
  }

  Widget buildTroparion(Troparion t) {
    List<Widget> content = [];

    final glas = t.glas ?? "";
    var title = t.title;

    if (glas.isNotEmpty) title += ", $glas";

    content.add(RichText(
      text: TextSpan(
          text: title,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
      textAlign: TextAlign.center,
    ));

    if ((t.url ?? "").isNotEmpty) {
      content.add(const SizedBox(height: 10));
      content.add(AudioPlayerView(t.url!));
      content.add(const SizedBox(height: 10));

    } else {
      content.add(const SizedBox(height: 20));
    }

    content.add(RichText(
        text: TextSpan(children: [
      TextSpan(
          text: "${t.content}\n",
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: fontSize))
    ])));
    content.add(const SizedBox(height: 10));

    return Column(children: content);
  }

  @override
  Widget build(BuildContext context) => BookPageSingle(
      title,
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.troparia.map((t) => buildTroparion(t)).toList()));
}
