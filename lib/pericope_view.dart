import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:after_init/after_init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/config_param.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'book_model.dart';
import 'bible_model.dart';
import 'book_page_single.dart';
import 'globals.dart';
import 'custom_list_tile.dart';


class BibleChapterView extends StatefulWidget {
  final BookPosition pos;
  final bool safeBottom;
  const BibleChapterView(this.pos, {required this.safeBottom});

  @override
  _BibleChapterViewState createState() => _BibleChapterViewState();
}

class _BibleChapterViewState extends State<BibleChapterView> {
  BookPosition get pos => widget.pos;

  bool ready = false;
  String title = "";
  late BibleUtil content;

  @override
  void initState() {
    super.initState();

    pos.model!.getTitle(pos).then((_title) {
      title = _title;
      return pos.model!.getContent(pos);
    }).then((_result) {
      content = _result;

      setState(() {
        ready = true;
      });
    });
  }

  Widget getContent() =>
      ready ? RichText(text: TextSpan(children: content.getTextSpan(context))) : Container();

  @override
  Widget build(BuildContext context) =>
      BookPageSingle(title, builder: () => getContent(), safeBottom: widget.safeBottom);
}

class PericopeView extends StatefulWidget {
  final String str;
  const PericopeView(this.str);

  @override
  _PericopeViewState createState() => _PericopeViewState();
}

class _PericopeViewState extends State<PericopeView> with AfterInitMixin<PericopeView> {
  bool ready = false;
  List<Widget> content = [];

  @override
  void didInitState() async {
    double fontSize = ConfigParam.fontSize.val();

    BibleUtil bu;
    final lang = context.countryCode;
    final pericope = widget.str.trim().split(" ");

    final model1 = OldTestamentModel(lang);
    final model2 = NewTestamentModel(lang);

    final allItems = model1.items.expand((e) => e).toList()..addAll(model2.items.expand((e) => e));

    final allFilenames = model1.filenames.expand((e) => e).toList()
      ..addAll(model2.filenames.expand((e) => e));

    for (final i in getRange(0, pericope.length, 2)) {
      var chapter = 0;
      var filename = pericope[i].toLowerCase();
      var bookName = allItems[allFilenames.indexOf(filename)].tr() + " " + pericope[i + 1];

      List<TextSpan> text = [];

      content.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: RichText(
              text: TextSpan(
                  text: bookName + "\n",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
              textAlign: TextAlign.center,
            ))
          ]));

      final arr2 = pericope[i + 1].split(",");

      for (final segment in arr2) {
        List<BibleRange> range = [];
        final arr3 = segment.split("-");

        for (final offset in arr3) {
          final arr4 = offset.split(":");

          if (arr4.length == 1) {
            range.add(BibleRange(chapter, int.parse(arr4[0])));
          } else {
            chapter = int.parse(arr4[0]);
            range.add(BibleRange(chapter, int.parse(arr4[1])));
          }
        }

        if (range.length == 1) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse=${range[0].verse}");

          text.addAll(bu.getTextSpan(context));
        } else if (range[0].chapter != range[1].chapter) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse>=${range[0].verse}");

          text.addAll(bu.getTextSpan(context));

          for (final chap in getRange(range[0].chapter + 1, range[1].chapter)) {
            bu = await BibleUtil.fetch(filename, lang, "chapter=$chap");
            text.addAll(bu.getTextSpan(context));
          }

          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[1].chapter} AND verse<=${range[1].verse}");

          text.addAll(bu.getTextSpan(context));
        } else {
          bu = await BibleUtil.fetch(filename, lang,
              "chapter=${range[0].chapter} AND verse>=${range[0].verse} AND verse<=${range[1].verse}");

          text.addAll(bu.getTextSpan(context));
        }
      }

      content.add(RichText(text: TextSpan(children: text)));
      content.add(const SizedBox(height: 20));
    }

    setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) => ready
      ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content)
      : Container();
}

class ReadingView extends StatefulWidget {
  final String r;
  const ReadingView(this.r);

  @override
  _ReadingViewState createState() => _ReadingViewState();
}

class _ReadingViewState extends State<ReadingView> with AfterInitMixin<ReadingView> {
  late String title;
  late String? subtitle;
  late List<String> currentReading;

  @override
  void didInitState() async {
    currentReading = widget.r.split("#");
    title = currentReading[0];
    subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;

    title = JSON.bibleTrans[context.countryCode]!.entries
        .fold(title, (String prev, e) => prev.replaceAll(e.key, e.value));
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => BookPageSingle("Gospel of the day".tr(),
              builder: () => PericopeView(currentReading[0])).push(context)));
}
