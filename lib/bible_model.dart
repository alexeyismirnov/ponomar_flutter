import 'package:group_list_view/group_list_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:async';
import 'dart:convert';

import 'book_model.dart';
import 'globals.dart';

class BibleVerse {
  final int verse;
  final String text;

  BibleVerse(this.verse, this.text);
}

class BibleUtil {
  List<BibleVerse> content = [];

  BibleUtil();

  BibleUtil.fromMap(List<Map<String, Object?>> data) {
    for (final Map<String, Object?> d in data) {
      content.add(BibleVerse(d["verse"] as int, d["text"] as String));
    }
  }

  static Future<BibleUtil> fetch(String bookName, String lang, String whereExpr) async {
    var db = await DB.open(bookName + "_$lang.sqlite");

    List<Map<String, Object?>> result =
        await db.query("scripture", columns: ["verse", "text"], where: whereExpr);

    return BibleUtil.fromMap(result);
  }

  String getText() {
    return content.map((line) => line.text).join("\n");
  }
}

mixin BibleModel on BookModel {
  List<List<String>> get items;
  List<List<String>> get filenames;

  @override
  Future prepare() async {
    filenames.expand((e) => e).forEach((f) async {
      await DB.prepare(basename: "assets/bible", filename: "${f}_$lang.sqlite");
    });
  }

  @override
  Future<int> getNumChapters(IndexPath index) async {
    final bookName = filenames[index.section][index.index];

    print(bookName);
    var db = await DB.open(bookName + "_$lang.sqlite");

    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(DISTINCT chapter) FROM scripture'))!;
  }

  @override
  Future<List<String>> getItems(int section) {
    return Future<List<String>>.value(items[section].map((s) => s.tr()).toList());
  }

  @override
  Future<String?> getTitle(BookPosition pos) {
    String? s;
    var index = pos.index;
    var chapter = pos.chapter;

    if (index == null || chapter == null) {
      return Future<String?>.value(null);
    } else if (filenames[index.section][index.index] == "ps") {
      s = "Kathisma %d".tr();
    } else {
      s = "Chapter %d".tr();
    }

    return Future<String?>.value(s.format([chapter + 1]));
  }

  @override
  Future getContent(BookPosition pos) async {
    var index = pos.index;
    var chapter = pos.chapter;

    if (index == null || chapter == null) {
      return Future<String?>.value(null);
    }

    final bookName = filenames[index.section][index.index];

    var result = await BibleUtil.fetch(bookName, lang, "chapter=${chapter + 1}");
    return result.getText();
  }
}

class OldTestamentModel extends BookModel with BibleModel {
  @override
  final items =
      jsonDecode(JSON.OldTestamentItems).map<List<String>>((l) => List<String>.from(l)).toList();

  @override
  final filenames = jsonDecode(JSON.OldTestamentFilenames)
      .map<List<String>>((l) => List<String>.from(l))
      .toList();

  @override
  String get code => "OldTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "Old Testament".tr();

  @override
  String? author;

  @override
  String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  OldTestamentModel(this.lang);

  @override
  Future<List<String>> getSections() {
    return Future<List<String>>.value([
      "Five Books of Moses",
      "Historical books",
      "Wisdom books",
      "Prophets books"
    ].map((s) => s.tr()).toList());
  }
}

class NewTestamentModel extends BookModel with BibleModel {
  @override
  final items =
      jsonDecode(JSON.NewTestamentItems).map<List<String>>((l) => List<String>.from(l)).toList();

  @override
  final filenames = jsonDecode(JSON.NewTestamentFilenames)
      .map<List<String>>((l) => List<String>.from(l))
      .toList();

  @override
  String get code => "NewTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "New Testament".tr();

  @override
  String? author;

  @override
  String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  NewTestamentModel(this.lang);

  @override
  Future<List<String>> getSections() {
    return Future<List<String>>.value([
      "Four Gospels and Acts",
      "Catholic Epistles",
      "Epistles of Paul",
      "Apocalypse"
    ].map((s) => s.tr()).toList());
  }
}
