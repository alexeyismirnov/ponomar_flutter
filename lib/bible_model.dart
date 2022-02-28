import 'package:group_list_view/group_list_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sqflite/sqflite.dart';

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
    var db = await openDB(bookName + "_$lang.sqlite");

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

  Future<int> numberOfChapters(String bookName) async {
    var db = await openDB(bookName + "_$lang.sqlite");
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(DISTINCT chapter) FROM scripture'))!;
  }

  Future<String> getChapter(String bookName, int chapter) async {
    var result = await BibleUtil.fetch(bookName, lang, "chapter=$chapter");
    return result.getText();
  }

  @override
  Future<int> getNumChapters(IndexPath index) {
    return Future<int>.value(0);
  }
}

class OldTestamentModel extends BookModel with BibleModel {
  @override
  final List<List<String>> items = jsonDecode(JSON.OldTestamentItems);

  @override
  final List<List<String>> filenames = jsonDecode(JSON.OldTestamentFilenames);

  @override
  String get code => "OldTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "Old Testament".tr();

  @override
  String? author;

  @override
  late String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  @override
  Future<List<String>> getSections() {
    return Future<List<String>>.value([]);
  }

  @override
  Future<List<String>> getItems(int sections) {
    return Future<List<String>>.value([]);
  }

  @override
  Future getContent(BookPosition pos) {
    return Future.value(null);
  }
}

class NewTestamentModel extends BookModel with BibleModel {
  @override
  final List<List<String>> items = jsonDecode(JSON.NewTestamentItems);

  @override
  final List<List<String>> filenames = jsonDecode(JSON.NewTestamentFilenames);

  @override
  String get code => "NewTestament";

  @override
  BookContentType get contentType => BookContentType.text;

  @override
  String get title => "New Testament".tr();

  @override
  String? author;

  @override
  late String lang;

  @override
  bool get hasChapters => true;

  @override
  Future get initFuture => Future.value(null);

  @override
  Future<List<String>> getSections() {
    return Future<List<String>>.value([]);
  }

  @override
  Future<List<String>> getItems(int sections) {
    return Future<List<String>>.value([]);
  }

  @override
  Future getContent(BookPosition pos) {
    return Future.value(null);
  }
}
