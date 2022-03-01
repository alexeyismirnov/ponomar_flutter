import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:after_init/after_init.dart';
import 'package:group_list_view/group_list_view.dart';

import 'calendar_appbar.dart';
import 'bible_model.dart';
import 'book_model.dart';
import 'globals.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with AfterInitMixin<LibraryPage> {
  late DateTime date;
  late DateTime savedDate;

  late List<List<BookModel>> books;
  final sections = ["Bible"];
  bool ready = false;

  @override
  void didInitState() {
    final lang = context.languageCode;

    books = [
      [OldTestamentModel(lang), NewTestamentModel(lang)]
    ];

    var futures = <Future>[];
    for (final model in books.expand((e) => e)) {
      futures.add(model.initFuture);
    }

    Future.wait(futures).then((_) => setState(() => ready = true));
  }

  Widget getContent() {
    if (!ready) return Container();

    return GroupListView(
      sectionsCount: sections.length,
      countOfItemInSection: (int section) => books[section].length,
      itemBuilder: (BuildContext context, IndexPath index) {
        return Padding(

          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        child: Text(books[index.section][index.index].title,
            style: Theme.of(context).textTheme.titleLarge));
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(sections[section].tr().toUpperCase(),
            style: Theme.of(context).textTheme.button),
          const Divider(thickness: 1)
          ]);
      },
      separatorBuilder: (context, index) => const SizedBox(),
      sectionSeparatorBuilder: (context, section) => const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                      [CalendarAppbar(title: "library", showActions: false)],
                  body: Padding(padding: EdgeInsets.all(15), child: getContent())))));
}
