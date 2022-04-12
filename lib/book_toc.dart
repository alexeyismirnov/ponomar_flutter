import 'package:flutter/material.dart';

import 'package:group_list_view/group_list_view.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:ponomar/bible_model.dart';

import 'calendar_appbar.dart';
import 'book_model.dart';
import 'globals.dart';
import 'pericope.dart';
import 'book_page_single.dart';
import 'book_cell.dart';

class _ChaptersView extends StatefulWidget {
  final BookPosition pos;
  const _ChaptersView(this.pos);

  @override
  _ChaptersViewState createState() => _ChaptersViewState();
}

class _ChaptersViewState extends State<_ChaptersView> {
  bool ready = false;
  BookPosition get pos => widget.pos;
  late int numChapters;

  @override
  void initState() {
    super.initState();

    pos.model!.getNumChapters(pos.index!).then((_numChapters) => setState(() {
          numChapters = _numChapters;
          ready = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Container();

    return Wrap(
        spacing: 0.0,
        runSpacing: 0.0,
        children: List<int>.generate(numChapters, (i) => i + 1)
            .map((i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    BookPositionNotification(BookPosition.modelIndex(pos.model, pos.index, i - 1))
                        .dispatch(context),
                child: SizedBox(
                    width: 50,
                    height: 50,
                    child:
                        Center(child: Text("$i", style: Theme.of(context).textTheme.titleLarge)))))
            .toList());
  }
}

class BookTOC extends StatefulWidget {
  final BookModel model;
  const BookTOC(this.model);

  @override
  _BookTOCState createState() => _BookTOCState();
}

class _BookTOCState extends State<BookTOC> {
  bool ready = false;
  BookModel get model => widget.model;

  late List<String> sections;
  late Map<int, List<String>> items = {};

  @override
  void initState() {
    super.initState();

    model.getSections().then((_sections) {
      sections = List<String>.from(_sections);
      List<Future> futures = [];

      sections.forEachIndexed((s, i) {
        futures.add(model.getItems(i).then((_items) => items[i] = List<String>.from(_items)));
      });

      Future.wait(futures);
    }).then((_) => setState(() => ready = true));
  }

  Widget getContent() {
    if (!ready) return Container();

    return NotificationListener<Notification>(
        onNotification: (n) {
          if (n is BookPositionNotification) {
            if (model is BibleModel) {
              BibleChapterView(n.pos).push(context);
            } else {
              String title = "";

              model.getTitle(n.pos).then((_title) {
                title = _title;
                return model.getContent(n.pos);
              }).then((text) {
                if (model.contentType == BookContentType.html) {
                  BookPageSingle(title, padding: 5, builder: () => BookCellHTML(text, model))
                      .push(context);
                } else {
                  BookPageSingle(title, builder: () => BookCellText(text)).push(context);
                }
              });
            }
          }
          return true;
        },
        child: GroupListView(
          shrinkWrap: true,
          sectionsCount: sections.length,
          countOfItemInSection: (int section) => items[section]!.length,
          itemBuilder: (BuildContext context, IndexPath index) {
            return ListTileTheme(
                contentPadding: const EdgeInsets.all(0),
                dense: true,
                child: model.hasChapters
                    ? ExpansionTile(
                        childrenPadding: const EdgeInsets.all(10),
                        expandedAlignment: Alignment.topLeft,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        trailing: const Icon(null),
                        title: Text(items[index.section]![index.index],
                            style: Theme.of(context).textTheme.titleLarge),
                        children: [_ChaptersView(BookPosition.modelIndex(model, index))])
                    : ListTile(
                        title: Text(items[index.section]![index.index],
                            style: Theme.of(context).textTheme.titleLarge),
                        onTap: () => BookPositionNotification(BookPosition.modelIndex(model, index))
                            .dispatch(context)));
          },
          groupHeaderBuilder: (BuildContext context, int section) => sections[section].isNotEmpty
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sections[section].toUpperCase(), style: Theme.of(context).textTheme.button),
                  const Divider(thickness: 1)
                ])
              : Container(),
          separatorBuilder: (context, index) => const SizedBox(),
          sectionSeparatorBuilder: (context, section) => const SizedBox(height: 15),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration:
                AppTheme.bg_decor_2() ?? BoxDecoration(color: Theme.of(context).canvasColor),
            child: SafeArea(
                child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                        [CalendarAppbar(title: model.title, showActions: false)],
                    body: Padding(padding: const EdgeInsets.all(15), child: getContent())))));
  }
}
