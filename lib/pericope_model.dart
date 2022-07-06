import 'package:easy_localization/easy_localization.dart';

import 'bible_model.dart';
import 'globals.dart';

class PericopeModel {
  final String lang;
  final String str;

  late Future initFuture;

  List<String> title = [];
  List<String> content = [];

  PericopeModel(this.lang, this.str) {
    initFuture = getPericope();
  }

  Future getPericope() async {
    final pericope = str.trim().split(" ");

    final model1 = OldTestamentModel(lang);
    final model2 = NewTestamentModel(lang);

    final allItems = model1.items.expand((e) => e).toList()..addAll(model2.items.expand((e) => e));

    final allFilenames = model1.filenames.expand((e) => e).toList()
      ..addAll(model2.filenames.expand((e) => e));

    BibleUtil bu;

    for (final i in getRange(0, pericope.length, 2)) {
      List<String> text = [];
      var chapter = 0;
      var filename = pericope[i].toLowerCase();
      var bookName = allItems[allFilenames.indexOf(filename)].tr();

      title.add(bookName);

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

          text.add(bu.getText());
        } else if (range[0].chapter != range[1].chapter) {
          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[0].chapter} AND verse>=${range[0].verse}");

          text.add(bu.getText());

          for (final chap in getRange(range[0].chapter + 1, range[1].chapter)) {
            bu = await BibleUtil.fetch(filename, lang, "chapter=$chap");
            text.add(bu.getText());
          }

          bu = await BibleUtil.fetch(
              filename, lang, "chapter=${range[1].chapter} AND verse<=${range[1].verse}");

          text.add(bu.getText());
        } else {
          bu = await BibleUtil.fetch(filename, lang,
              "chapter=${range[0].chapter} AND verse>=${range[0].verse} AND verse<=${range[1].verse}");

          text.add(bu.getText());
        }
      }

      content.add(text.join(" "));
    }
  }
}
