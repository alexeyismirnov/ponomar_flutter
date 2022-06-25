import 'package:flutter/material.dart';
import 'package:ponomar/book_model.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';
import 'package:group_list_view/group_list_view.dart';

import 'church_calendar.dart';
import 'custom_list_tile.dart';
import 'book_page_single.dart';
import 'book_cell.dart';
import 'ebook_model.dart';
import 'globals.dart';

class SynaxarionView extends StatelessWidget {
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

    final index = dates.indexOf(date);

    if (index == -1) {
      return null;
    } else {
      final model = EbookModel("synaxarion_${context.languageCode}.sqlite");
      await model.initFuture;

      final pos = BookPosition.index(IndexPath(section: 0, index: index));
      final title = await model.getTitle(pos);
      final text = await model.getContent(pos);

      final content = BookCellHTML(text, model);

      return CustomListTile(
          title: title,
          onTap: () => BookPageSingle(title, padding: 5, builder: () => content).push(context));
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
