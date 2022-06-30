import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:after_init/after_init.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'custom_list_tile.dart';
import 'calendar_appbar.dart';
import 'bible_model.dart';
import 'book_model.dart';
import 'globals.dart';
import 'book_toc.dart';
import 'ebook_model.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with AfterInitMixin<LibraryPage> {
  late DateTime date;
  late DateTime savedDate;

  late List<List<BookModel>> books;
  List<String> sections = [];
  bool ready = false;

  @override
  void didInitState() {
    final lang = context.countryCode;

    sections = ["Bible"];

    books = [
      [OldTestamentModel(lang), NewTestamentModel(lang)]
    ];

    if (lang == "ru") {
      sections.add("Молитвослов");
      books.add([
        EbookModel("prayerbook_$lang.sqlite"),
        EbookModel("canons.sqlite"),
      ]);

      sections.add("liturgical-books".tr());
      books.add([
        EbookModel("vigil_$lang.sqlite"),
        EbookModel("liturgy_$lang.sqlite"),
      ]);

      sections.add("other".tr());
      books.add([
        EbookModel("synaxarion_ru.sqlite"),
        EbookModel("old_testament_overview.sqlite"),
        EbookModel("new_testament_overview.sqlite"),
        EbookModel("zerna.sqlite"),
        EbookModel("zvezdinsky.sqlite"),
      ]);
    } else {
      sections.add("liturgical-books".tr());
      books.add([
        EbookModel("vigil_$lang.sqlite"),
        EbookModel("liturgy_$lang.sqlite"),
      ]);

      sections.add("other".tr());
      books.add([EbookModel("prayerbook_$lang.sqlite"), EbookModel("synaxarion_$lang.sqlite")]);
    }

    var futures = <Future>[];
    for (final model in books.expand((e) => e)) {
      futures.add(model.initFuture);
    }

    Future.wait(futures).then((_) => setState(() => ready = true));
  }

  Widget getContent() {
    if (!ready) return Container();

    return GroupListView(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      sectionsCount: sections.length,
      countOfItemInSection: (int section) => books[section].length,
      itemBuilder: (BuildContext context, IndexPath index) {
        return CustomListTile(
          padding: 10,
          reversed: true,
          onTap: () => BookTOC(books[index.section][index.index]).push(context),
          title: books[index.section][index.index].title,
          subtitle: books[index.section][index.index].author ?? "",
        );
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sections[section].tr().toUpperCase(), style: Theme.of(context).textTheme.button),
          const Divider(thickness: 1)
        ]);
      },
      separatorBuilder: (context, index) => const SizedBox(),
      sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
              [CalendarAppbar(title: "library", showActions: false)],
          body: Padding(padding: const EdgeInsets.all(15), child: getContent())));
}
