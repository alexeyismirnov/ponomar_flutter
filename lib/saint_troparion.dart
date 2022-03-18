import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';
import 'package:after_init/after_init.dart';

import 'troparion_model.dart';
import 'church_calendar.dart';
import 'book_page_single.dart';

class SaintTroparionModel {
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
    Database db;
    List<Troparion> result = [];

    db = await DB.open("troparion.sqlite");

    List<Map<String, Object?>> data = await db.query("tropari",
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

class _SaintTroparionViewState extends State<SaintTroparionView> with AfterInitMixin<SaintTroparionView> {
  String title = "Тропари и кондаки";
  List<Widget> content = [];

  @override
  void didInitState()  {
    double fontSize = ConfigParam.fontSize.val();

    for (final t in widget.troparia) {
      final glas = t.glas ?? "";
      var title = t.title;

      if (glas.isNotEmpty) title += ", $glas";

      content.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: RichText(
              text: TextSpan(
                  text: title + "\n",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
              textAlign: TextAlign.center,
            ))
          ]));

      content.add(RichText(
          text: TextSpan(children: [
        TextSpan(
            text: "${t.content}\n",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: fontSize))
      ])));
      content.add(const SizedBox(height: 10));
    }
  }

  @override
  Widget build(BuildContext context) => BookPageSingle(
      title,
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content));
}
