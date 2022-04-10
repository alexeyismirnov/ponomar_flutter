import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'church_reading.dart';

class SynaxarionView extends StatelessWidget {
  static Database? db;
  final DateTime date;
  final Cal cal;

  SynaxarionView(this.date) : cal = Cal.fromDate(date);

  Future<Widget?> fetch(BuildContext context) async {
    final dates = [
      cal.greatLentStart - 22.days,
      cal.greatLentStart - 15.days,
      cal.greatLentStart - 9.days,
      cal.greatLentStart - 8.days,
      cal.greatLentStart - 2.days,
      cal.greatLentStart - 1.days,
      cal.greatLentStart + 5.days,
      cal.greatLentStart + 6.days,
      cal.greatLentStart + 13.days,
      cal.greatLentStart + 20.days,
      cal.greatLentStart + 27.days,
      cal.greatLentStart + 31.days,
      cal.greatLentStart + 33.days,
      cal.pascha - 8.days,
      cal.pascha - 7.days,
      cal.pascha - 6.days,
      cal.pascha - 5.days,
      cal.pascha - 4.days,
      cal.pascha - 3.days,
      cal.pascha - 2.days,
      cal.pascha - 1.days,
      cal.pascha,
      cal.pascha + 5.days,
      cal.pascha + 7.days,
      cal.pascha + 14.days,
      cal.pascha + 21.days,
      cal.pascha + 24.days,
      cal.pascha + 28.days,
      cal.pascha + 35.days,
      cal.pascha + 42.days,
      cal.pascha + 39.days,
      cal.pascha + 49.days,
      cal.pascha + 50.days,
      cal.pascha + 56.days,
    ];

    int fontSize = ConfigParam.fontSize.val().round();

    const svg = """
    <svg id="Layer_1"  viewBox="0 0 24 24" >
    <g transform="scale(0.5)">
    <path style="fill: red" clip-rule="evenodd" d="M37,47H11c-2.209,0-4-1.791-4-4V5c0-2.209,1.791-4,4-4h18.973  c0.002,0,0.005,0,0.007,0h0.02H30c0.32,0,0.593,0.161,0.776,0.395l9.829,9.829C40.84,11.407,41,11.68,41,12l0,0v0.021  c0,0.002,0,0.003,0,0.005V43C41,45.209,39.209,47,37,47z M31,4.381V11h6.619L31,4.381z M39,13h-9c-0.553,0-1-0.448-1-1V3H11  C9.896,3,9,3.896,9,5v38c0,1.104,0.896,2,2,2h26c1.104,0,2-0.896,2-2V13z M33,39H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18  c0.553,0,1,0.448,1,1C34,38.553,33.553,39,33,39z M33,31H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1  C34,30.553,33.553,31,33,31z M33,23H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1C34,22.553,33.553,23,33,23  z" fill-rule="evenodd"/>
    </g>
    </svg>
    """;

    String css = """
        <style type='text/css'>
        body {font-size: ${fontSize}px;  }
        a { text-decoration: none; }
        .rubric { color: red; font-size: 90%; }
        .author { color: red; font-size: 110%; font-weight:bold; }
        </style>
        """;

    db ??= await DB.open("synaxarion.sqlite");

    final index = dates.indexOf(date);

    if (index == -1) {
      return null;
    } else {
      var data =
          (await db!.query("content", columns: ["title", "text"], where: "item=$index")).first;

      var text = data["text"] as String;
      text = text.replaceAllMapped(RegExp(r'comment_(\d+)', caseSensitive: false),
          (Match m) => "&nbsp;<a href=\"comment://${m[1]}\">$svg</a>&nbsp;");

      final content = Html(
          data: css + text,
          onLinkTap: (String? url, RenderContext context, Map<String, String> attributes,
              dom.Element? element) {
            print(url);
          });

      return CustomListTile(
          title: data["title"] as String,
          onTap: () => BookPageSingle(data["title"] as String, padding: 5, builder: () => content)
              .push(context));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
      future: fetch(context),
      builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
        final result = snapshot.data;

        if (result != null) {
          return Column(children: [result] + <Widget>[const SizedBox(height: 5)]);
        }

        return Container();
      });
}
